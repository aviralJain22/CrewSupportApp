// trip_model.dart
//
// Simple model to represent a Trip returned by the get*Trips cloud functions (owner/pilot/attendant).
// This maps the JSON structure that the cloud function returns.

import 'trip_draft_payload.dart';

class TripModel {
  final String objectId;
  final String tripName;

  // Role flags + names
  final bool isCaptain;
  final String captain;
  final bool isSIC;
  final String sic;
  final bool isAttendant;
  final String attendant;
  final bool isInstructor;
  final String instructor;

  // Rates
  final num? pilotRate;
  final num? sicRate;
  final num? attendantRate;
  final num? instructorRate;

  // Routing (new fields: airports.csv sourceId)
  final int? departureSourceId;
  final int? destinationSourceId;
  final List<int> enrouteSourceIds;

  // Dates
  final DateTime? startDate;
  final DateTime? endDate;

  // Aircraft
  final String aircraft;
  // Requirements file (Parse File URL)
  final String? requirementsUrl;

  // Status flags
  final bool isStarted;
  final bool isCompleted;
  final bool isVoid;
  final bool isRead;
  final bool isDirect;

  // Other
  final num? radius;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TripModel({
    required this.objectId,
    required this.tripName,
    required this.isCaptain,
    required this.captain,
    required this.isSIC,
    required this.sic,
    required this.isAttendant,
    required this.attendant,
    required this.isInstructor,
    required this.instructor,
    required this.pilotRate,
    required this.sicRate,
    required this.attendantRate,
    required this.instructorRate,
    required this.departureSourceId,
    required this.destinationSourceId,
    required this.enrouteSourceIds,
    required this.startDate,
    required this.endDate,
    required this.aircraft,
    required this.requirementsUrl,
    required this.isStarted,
    required this.isCompleted,
    required this.isVoid,
    required this.isRead,
    required this.isDirect,
    required this.radius,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  String toString() {
    return 'TripModel(objectId: $objectId, tripName: $tripName, isCaptain: $isCaptain, captain: $captain, isSIC: $isSIC, sic: $sic, isAttendant: $isAttendant, attendant: $attendant, isInstructor: $isInstructor, instructor: $instructor, pilotRate: $pilotRate, sicRate: $sicRate, attendantRate: $attendantRate, instructorRate: $instructorRate, departureSourceId: $departureSourceId, destinationSourceId: $destinationSourceId, enrouteSourceIds: $enrouteSourceIds, startDate: $startDate, endDate: $endDate, aircraft: $aircraft, requirementsUrl: $requirementsUrl, isStarted: $isStarted, isCompleted: $isCompleted, isVoid: $isVoid, isRead: $isRead, isDirect: $isDirect, radius: $radius, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static List<int> _parseIntList(dynamic v) {
    if (v == null) return <int>[];
    if (v is List) {
      return v
          .map((e) => _parseInt(e))
          .whereType<int>()
          .toList(growable: false);
    }
    return <int>[];
  }

  /// Helper to parse a Parse Date JSON `{ "__type": "Date", "iso": "..." }`
  static DateTime? _parseParseDate(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      final iso = value['iso'];
      if (iso is String && iso.isNotEmpty) {
        return DateTime.tryParse(iso);
      }
    }
    // In case the SDK already returns DateTime directly
    if (value is DateTime) return value;
    return null;
  }

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      objectId: json['objectId'] as String,
      tripName: (json['tripName'] ?? '') as String,
      isCaptain: (json['isCaptain'] ?? false) as bool,
      captain: (json['captain'] ?? '') as String,
      isSIC: (json['isSIC'] ?? false) as bool,
      sic: (json['SIC'] ?? '') as String,
      isAttendant: (json['isAttendant'] ?? false) as bool,
      attendant: (json['attendant'] ?? '') as String,
      isInstructor: (json['isInstructor'] ?? false) as bool,
      instructor: (json['instructor'] ?? '') as String,
      pilotRate: json['pilotRate'] as num?,
      sicRate: json['SICRate'] as num?,
      attendantRate: json['attendantRate'] as num?,
      instructorRate: json['instructorRate'] as num?,
      departureSourceId: _parseInt(json['departureSourceId']),
      destinationSourceId: _parseInt(json['destinationSourceId']),
      enrouteSourceIds: _parseIntList(json['enrouteSourceIds']),
      startDate: _parseParseDate(json['startDate']),
      endDate: _parseParseDate(json['endDate']),
      aircraft: (json['aircraft'] ?? '') as String,
      requirementsUrl: json['requirementsUrl'] as String?,
      isStarted: (json['isStarted'] ?? false) as bool,
      isCompleted: (json['isCompleted'] ?? false) as bool,
      isVoid: (json['isVoid'] ?? false) as bool,
      isRead: (json['isRead'] ?? false) as bool,
      isDirect: (json['isDirect'] ?? false) as bool,
      radius: json['radius'] as num?,
      createdAt: _parseParseDate(json['createdAt']),
      updatedAt: _parseParseDate(json['updatedAt']),
    );
  }
  /// Convert this TripModel (returned from cloud function)
  /// into a TripDraftPayload so it can be loaded into the trip-creation flow.
  TripDraftPayload toDraftPayload() {
    return TripDraftPayload(
      tripObjectId: objectId,
      departureSourceId: departureSourceId,
      destinationSourceId: destinationSourceId,
      enrouteSourceIds: List<int>.from(enrouteSourceIds),
      tripName: tripName,
      startDate: startDate,
      endDate: endDate,
      aircraftName: aircraft,
      radius: radius?.toInt(),

      // Rates
      pilotRate: pilotRate,
      sicRate: sicRate,
      attendantRate: attendantRate,
      instructorRate: instructorRate,

      // Role flags
      isCaptain: isCaptain,
      isSIC: isSIC,
      isAttendant: isAttendant,
      isInstructor: isInstructor,

      // Status flags
      isStarted: isStarted,
      isCompleted: isCompleted,
      isVoid: isVoid,
      isRead: isRead,
      isDirect: isDirect,

      // roleRequirements are stored as a file in TripModel,
      // so initialize empty here. Caller can fetch & decode JSON
      // from requirementsUrl and inject into the draft if needed.
      roleRequirements: <String, dynamic>{},
    );
  }
}