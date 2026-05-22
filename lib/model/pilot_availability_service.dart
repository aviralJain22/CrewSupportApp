import 'package:crew_support/features/dashboard_controller.dart';
import 'package:crew_support/utils/membership_constants.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Simple value class to hold a lat/lng pair on Flutter side.
/// (We keep it decoupled from ParseGeoPoint so it’s easy to use in the app.)
class LatLngValue {
  final double latitude;
  final double longitude;

  LatLngValue(this.latitude, this.longitude);
}

/// Model representing one pilotAvailability document from Back4App.
///
/// It corresponds to your "pilotAvailability" class schema.
class AvailabilityItem {
  final String id;
  final bool? isAvailability;
  final bool? isVoid;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? comment;
  final String? airportCode;
  final LatLngValue? latLong;
  /// Computed flags (same as old Flutter model)
  final bool isCurrent;
  final bool isFuture;
  final bool isPast;

  AvailabilityItem({
    required this.id,
    this.isAvailability,
    this.isVoid,
    this.fromDate,
    this.toDate,
    this.comment,
    this.airportCode,
    this.latLong,
    required this.isCurrent,
    required this.isFuture,
    required this.isPast,
  });

  @override
  String toString() {
    return 'AvailabilityItem('
        'id: $id, '
        'isAvailability: $isAvailability, '
        'isVoid: $isVoid, '
        'fromDate: $fromDate, '
        'toDate: $toDate, '
        'comment: $comment, '
        'airportCode: $airportCode, '
        'latLong: $latLong, '
        'isCurrent: $isCurrent, '
        'isFuture: $isFuture, '
        'isPast: $isPast'
        ')';
  }

  /// Create a PilotAvailability from the JSON you get from Cloud Code:
  /// {
  ///   "objectId": "...",
  ///   "IsAvailability": true/false,
  ///   "IsVoid": false,
  ///   "FromDate": "2020-04-19T01:10:00.000Z",
  ///   "ToDate":   "2020-04-25T01:10:00.000Z",
  ///   "Comment": "...",
  ///   "AirportCode": "...",
  ///   "LatLong": { "__type": "GeoPoint", "latitude": 12.34, "longitude": 56.78 },
  ///   ...
  /// }
  factory AvailabilityItem.fromJson(Map<String, dynamic> json) {
    // Parse dates safely (if present)
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;

      // Case 1: Cloud Function / Parse toJSON() style:
      // { "__type": "Date", "iso": "2025-12-15T18:30:00.000Z" }
      if (value is Map<String, dynamic>) {
        final type = value['__type'];
        final iso = value['iso'];
        if (type == 'Date' && iso is String) {
          final dt = DateTime.tryParse(iso);
          return dt?.toLocal(); // 👈 convert to local time (IST for you)
        }
      }

      // Case 2: raw ISO string (just in case)
      if (value is String) {
        final dt = DateTime.tryParse(value);
        return dt?.toLocal(); // 👈 also local
      }

      return null;
    }

    // Parse GeoPoint → LatLngValue
    LatLngValue? _parseLatLong(dynamic value) {
      if (value == null || value is! Map<String, dynamic>) return null;
      final type = value['__type'];
      if (type == 'GeoPoint') {
        final lat = value['latitude'];
        final lng = value['longitude'];
        if (lat is num && lng is num) {
          return LatLngValue(lat.toDouble(), lng.toDouble());
        }
      }
      return null;
    }

    final from = _parseDate(json['FromDate']);
    final to = _parseDate(json['ToDate']);

    // Use UTC to be consistent with Parse ISO dates
    // final now = DateTime.now().toUtc();
    final now = DateTime.now();

    // CURRENT → now between from/to
    // final bool current = (from != null && to != null)
    //     ? now.isAfter(from) && now.isBefore(to)
    //     : false;

    final bool current = (from != null && to != null)
        ? (now.isAfter(from) && now.isBefore(to) ||
          now.isAtSameMomentAs(from) ||
          now.isAtSameMomentAs(to))
        : false;

    // FUTURE → FromDate is after now
    final bool future = (from != null) ? from.isAfter(now) : false;

    // PAST → ToDate is before now
    final bool past = (to != null) ? to.isBefore(now) : false;

    return AvailabilityItem(
      id: json['objectId'] as String? ?? '',
      isAvailability: json['IsAvailability'] as bool?,
      isVoid: json['IsVoid'] as bool?,
      fromDate: from,
      toDate: to,
      comment: json['Comment'] as String?,
      airportCode: (json['AirportCode'] ?? json['Zip']) as String?,
      latLong: _parseLatLong(json['LatLong']),
      isCurrent: current,
      isFuture: future,
      isPast: past,
    );
  }
}

/// Result of createPilotAvailability cloud function.
/// Mirrors the Cloud Code return:
///   { code: 1, availabilityId: "<id>" }  or
///   { code: 0, message: "Overlapping availability exists" }
class CreateAvailabilityResult {
  final int code;
  final String? availabilityId;
  final String? message;

  bool get isSuccess => code == 1;

  CreateAvailabilityResult({
    required this.code,
    this.availabilityId,
    this.message,
  });

  factory CreateAvailabilityResult.fromJson(Map<String, dynamic> json) {
    return CreateAvailabilityResult(
      code: (json['code'] as num?)?.toInt() ?? 0,
      availabilityId: json['availabilityId'] as String?,
      message: json['message'] as String?,
    );
  }
}

/// Service / helper functions for pilot availability Cloud Functions.
///
/// You can call these from your GetX controllers / blocs / providers.
class AvailabilityService {
  /// Helper: convert LatLngValue to the shape Cloud Code expects.
  /// We send `{ "lat": ..., "lng": ... }`, which the Cloud Code
  /// converts to Parse.GeoPoint.
  static Map<String, dynamic>? _latLngToParam(LatLngValue? latLng) {
    if (latLng == null) return null;
    return <String, dynamic>{
      'lat': latLng.latitude,
      'lng': latLng.longitude,
    };
  }

    // -----------------------------
    // Cloud Function name resolver
    // -----------------------------

    /// Returns true when the currently selected dashboard profile is Flight Attendant.
    ///
    /// We intentionally avoid importing the MembershipType enum here to keep the
    /// service decoupled; we use `toString()` matching instead.
    static bool _isFlightAttendantSelected() {
      try {
        if (!Get.isRegistered<DashboardController>()) return false;
        final dashboard = Get.find<DashboardController>();
        final v = dashboard.selectedProfileType.value;

        // Matches typical enum string forms like:
        //   MembershipType.flightAttendant
        //   flightAttendant
        //   attendant
        return (v == MembershipType.flightAttendant);
      } catch (_) {
        // If dashboard controller isn't available yet, default to pilot.
        return false;
      }
    }

    static String _fn(String pilotFn, String attendantFn) {
      return _isFlightAttendantSelected() ? attendantFn : pilotFn;
    }


  /// 1) Create a new availability block for the current logged-in pilot.
  ///
  /// This hits Cloud Code: "createPilotAvailability"
  ///
  /// Throws an Exception if the Parse call itself fails.
  /// Otherwise returns a CreateAvailabilityResult:
  ///   - result.isSuccess == true → created OK
  ///   - result.isSuccess == false → overlapping or other logical issue
  static Future<CreateAvailabilityResult> createAvailability({
    required bool isAvailability,
    required DateTime fromDate,
    required DateTime toDate,
    String? comment,
    String? airportCode,
    LatLngValue? latLong,
  }) async {
    // We send ISO strings so Cloud Code can parse with new Date(...).
    final params = <String, dynamic>{
      'isAvailability': isAvailability,
      'fromDate': fromDate.toUtc().toIso8601String(),
      'toDate': toDate.toUtc().toIso8601String(),
      if (comment != null && comment.isNotEmpty) 'comment': comment,
      if (airportCode != null && airportCode.isNotEmpty) 'airportCode': airportCode,
      if (latLong != null) 'latLong': _latLngToParam(latLong),
    };

    final func = ParseCloudFunction(_fn('createPilotAvailability', 'createAttendantAvailability'));
    final ParseResponse response = await func.execute(parameters: params);

    if (!response.success || response.result == null) {
      // Network/Parse-level failure
      throw Exception(
        'createPilotAvailability failed: ${response.error?.message ?? "Unknown error"}',
      );
    }

    final Map<String, dynamic> json = Map<String, dynamic>.from(response.result);
    return CreateAvailabilityResult.fromJson(json);
  }

  /// Internal helper to convert `{"items":[...objects...]}` to List<PilotAvailability>.
  static List<AvailabilityItem> _parseListResult(dynamic result) {
    if (result == null) return <AvailabilityItem>[];

    final map = Map<String, dynamic>.from(result);
    final items = map['items'];

    if (items is List) {
      return items
          .map((e) => AvailabilityItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return <AvailabilityItem>[];
  }

  /// 2) Get current + future availability for current pilot.
  ///
  /// Hits Cloud Code: "getPilotAvailabilitySchedule"
  ///
  /// Returns a list of PilotAvailability entries, with current entries first,
  /// then future entries – mirroring MySQL logic.
  static Future<List<AvailabilityItem>> getPilotAvailabilitySchedule() async {
    final func = ParseCloudFunction(_fn('getPilotAvailabilitySchedule', 'getAttendantAvailabilitySchedule'));
    final ParseResponse response = await func.execute();

    if (!response.success || response.result == null) {
      throw Exception(
        'getPilotAvailabilitySchedule failed: ${response.error?.message ?? "Unknown error"}',
      );
    }

    return _parseListResult(response.result);
  }

  /// 3) Get future unavailability (IsAvailability == false, FromDate > now).
  ///
  /// Hits Cloud Code: "getPilotFutureUnavailability"
  static Future<List<AvailabilityItem>> getPilotFutureUnavailability() async {
    final func = ParseCloudFunction(_fn('getPilotFutureUnavailability', 'getAttendantFutureUnavailability'));
    final ParseResponse response = await func.execute();

    if (!response.success || response.result == null) {
      throw Exception(
        'getPilotFutureUnavailability failed: ${response.error?.message ?? "Unknown error"}',
      );
    }

    return _parseListResult(response.result);
  }

  /// 4) Get past/current unavailability (IsAvailability == false, FromDate <= now).
  ///
  /// Hits Cloud Code: "getPilotPastUnavailability"
  static Future<List<AvailabilityItem>> getPilotPastUnavailability() async {
    final func = ParseCloudFunction(_fn('getPilotPastUnavailability', 'getAttendantPastUnavailability'));
    final ParseResponse response = await func.execute();

    if (!response.success || response.result == null) {
      throw Exception(
        'getPilotPastUnavailability failed: ${response.error?.message ?? "Unknown error"}',
      );
    }

    return _parseListResult(response.result);
  }

  /// 5) Delete an availability row (hard delete)
  ///
  /// Calls Cloud Code: deletePilotAvailability
  ///
  /// Returns DeleteAvailabilityResult:
  ///   - result.isSuccess == true → deleted OK
  ///   - result.isSuccess == false → not found / not allowed
  static Future<DeleteAvailabilityResult> deletePilotAvailability(
      String availabilityId) async {
    final func = ParseCloudFunction(_fn('deletePilotAvailability', 'deleteAttendantAvailability'));

    final ParseResponse response =
        await func.execute(parameters: {'availabilityId': availabilityId});

    if (!response.success || response.result == null) {
      throw Exception(
        'deletePilotAvailability failed: ${response.error?.message ?? "Unknown error"}',
      );
    }

    final Map<String, dynamic> json =
        Map<String, dynamic>.from(response.result);

    return DeleteAvailabilityResult.fromJson(json);
  }

  /// Update an existing availability block for the current logged-in pilot.
  ///
  /// Calls Cloud Code: "updatePilotAvailability"
  ///
  /// Parameters:
  /// - availabilityId : the objectId of the pilotAvailability to update
  /// - isAvailability : optional; if null, backend will keep existing value
  /// - fromDate / toDate : required; full-day DateTime values
  /// - comment / airportCode : optional; if null, backend keeps existing
  /// - latLong : optional location
  ///
  /// Returns:
  ///   UpdateAvailabilityResult
  ///     - result.isSuccess == true  → updated OK
  ///     - result.isSuccess == false → logical error (e.g. overlap)
  static Future<UpdateAvailabilityResult> updatePilotAvailability({
    required String availabilityId,
    required DateTime fromDate,
    required DateTime toDate,
    bool? isAvailability,
    String? comment,
    String? airportCode,
    LatLngValue? latLong,
  }) async {
    // Convert dates to ISO UTC strings for Cloud Code.
    final params = <String, dynamic>{
      'availabilityId': availabilityId,
      'fromDate': fromDate.toUtc().toIso8601String(),
      'toDate': toDate.toUtc().toIso8601String(),
      if (isAvailability != null) 'isAvailability': isAvailability,
      if (comment != null) 'comment': comment,
      if (airportCode != null) 'airportCode': airportCode,
      if (latLong != null)
        'latLong': {
          'lat': latLong.latitude,
          'lng': latLong.longitude,
        },
    };

    final func = ParseCloudFunction(_fn('updatePilotAvailability', 'updateAttendantAvailability'));
    final ParseResponse response = await func.execute(parameters: params);

    if (!response.success || response.result == null) {
      // Network/Parse-level failure, not logical failure.
      throw Exception(
        'updatePilotAvailability failed: ${response.error?.message ?? "Unknown error"}',
      );
    }

    final Map<String, dynamic> json =
        Map<String, dynamic>.from(response.result);

    return UpdateAvailabilityResult.fromJson(json);
  }
}

class DeleteAvailabilityResult {
  final int code;
  final String? availabilityId;
  final String? message;

  bool get isSuccess => code == 1;

  DeleteAvailabilityResult({
    required this.code,
    this.availabilityId,
    this.message,
  });

  factory DeleteAvailabilityResult.fromJson(Map<String, dynamic> json) {
    return DeleteAvailabilityResult(
      code: (json['code'] as num?)?.toInt() ?? 0,
      availabilityId: json['availabilityId'] as String?,
      message: json['message'] as String?,
    );
  }
}

/// Result of updatePilotAvailability cloud function.
///
/// Cloud Code returns:
///   { code: 1, availabilityId: "<id>" }
/// or
///   { code: 0, message: "Updated dates overlap..." }
class UpdateAvailabilityResult {
  final int code;
  final String? availabilityId;
  final String? message;

  bool get isSuccess => code == 1;

  UpdateAvailabilityResult({
    required this.code,
    this.availabilityId,
    this.message,
  });

  factory UpdateAvailabilityResult.fromJson(Map<String, dynamic> json) {
    return UpdateAvailabilityResult(
      code: (json['code'] as num?)?.toInt() ?? 0,
      availabilityId: json['availabilityId'] as String?,
      message: json['message'] as String?,
    );
  }
}