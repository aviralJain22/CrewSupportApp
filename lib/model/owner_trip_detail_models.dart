// lib/model/owner_trip_detail_models.dart
//
// Models for Parse Cloud Function: getOwnerTripDetail
// Response shape:
// {
//   "trip": { ... },
//   "crewList": [ { ... }, ... ]
// }
// Note:
// Each crewList item now includes userId to uniquely identify the user.
//
// Note:
// Parse Server may return Date fields in one of these formats:
// 1) ISO8601 String ("2025-12-17T00:00:00.000Z")
// 2) Parse Date JSON: { "__type": "Date", "iso": "..." }
// 3) Already-decoded DateTime (rare, but possible depending on client)

class TripCrewMemberModel {
  final String role; // captain | sic | attendant | instructor
  final String profileClass;
  final String profileId;
  /// Unique user identifier for the crew member
  final String userId;
  final String firstName;
  final String lastName;
  final String profilePictureUrl;
  final int membershipType;
  final int badgeCount;

  TripCrewMemberModel({
    required this.role,
    required this.profileClass,
    required this.profileId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.profilePictureUrl,
    required this.membershipType,
    required this.badgeCount,
  });

  String get fullName {
    final fn = firstName.trim();
    final ln = lastName.trim();
    if (fn.isEmpty && ln.isEmpty) return '';
    if (ln.isEmpty) return fn;
    if (fn.isEmpty) return ln;
    return '$fn $ln';
  }

  /// Human-friendly role label for UI.
  String get roleLabel {
    switch (role) {
      case 'captain':
        return 'Captain';
      case 'sic':
        return 'Second In Command';
      case 'attendant':
        return 'Flight Attendant';
      case 'instructor':
        return 'Instructor';
      case 'owner':
        return 'Owner/Operator';
      default:
        return role;
    }
  }

  factory TripCrewMemberModel.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return TripCrewMemberModel(
      role: (json['role'] ?? '').toString(),
      profileClass: (json['profileClass'] ?? '').toString(),
      profileId: (json['profileId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      profilePictureUrl: (json['profilePictureUrl'] ?? '').toString(),
      membershipType: _int(json['membershipType']),
      badgeCount: _int(json['badgeCount']),
    );
  }
}

class OwnerTripDetailModel {
  final String objectId;
  final String ownerId;
  final String tripName;
  // Routing (new fields: airports.csv sourceId)
  final int? departureSourceId;
  final int? destinationSourceId;
  final List<int> enrouteSourceIds;
  final String aircraft;

  final bool isCaptain;
  final bool isSIC;
  final bool isAttendant;
  final bool isInstructor;

  final num? pilotRate;
  final num? sicRate;
  final num? attendantRate;
  final num? instructorRate;

  final DateTime? startDate;
  final DateTime? endDate;

  final bool isStarted;
  final bool isCompleted;
  final bool isVoid;
  final bool isRead;
  final bool isDirect;

  final num? radius;

  final num? updatePilotRate;
  final num? updateSICRate;
  final num? updateAttendantRate;
  final num? updateInstructorRate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  OwnerTripDetailModel({
    required this.objectId,
    required this.ownerId,
    required this.tripName,
    required this.departureSourceId,
    required this.destinationSourceId,
    required this.enrouteSourceIds,
    required this.aircraft,
    required this.isCaptain,
    required this.isSIC,
    required this.isAttendant,
    required this.isInstructor,
    required this.pilotRate,
    required this.sicRate,
    required this.attendantRate,
    required this.instructorRate,
    required this.startDate,
    required this.endDate,
    required this.isStarted,
    required this.isCompleted,
    required this.isVoid,
    required this.isRead,
    required this.isDirect,
    required this.radius,
    required this.updatePilotRate,
    required this.updateSICRate,
    required this.updateAttendantRate,
    required this.updateInstructorRate,
    required this.createdAt,
    required this.updatedAt,
  });

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

  factory OwnerTripDetailModel.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;

      // Parse Date JSON: {"__type":"Date","iso":"..."}
      if (value is Map) {
        final iso = value['iso'];
        if (iso is String && iso.isNotEmpty) {
          return DateTime.tryParse(iso);
        }
      }

      // ISO8601 string
      if (value is String) {
        return DateTime.tryParse(value);
      }

      // Already-decoded DateTime
      if (value is DateTime) return value;

      return null;
    }

    num? _num(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      return num.tryParse(v.toString());
    }

    bool _bool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      final s = v.toString().toLowerCase().trim();
      return s == 'true' || s == '1';
    }

    return OwnerTripDetailModel(
      objectId: (json['objectId'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      tripName: (json['tripName'] ?? '').toString(),
      departureSourceId: _parseInt(json['departureSourceId']),
      destinationSourceId: _parseInt(json['destinationSourceId']),
      enrouteSourceIds: _parseIntList(json['enrouteSourceIds']),
      aircraft: (json['aircraft'] ?? '').toString(),
      isCaptain: _bool(json['isCaptain']),
      isSIC: _bool(json['isSIC']),
      isAttendant: _bool(json['isAttendant']),
      isInstructor: _bool(json['isInstructor']),
      pilotRate: _num(json['pilotRate']),
      sicRate: _num(json['SICRate']),
      attendantRate: _num(json['attendantRate']),
      instructorRate: _num(json['instructorRate']),
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      isStarted: _bool(json['isStarted']),
      isCompleted: _bool(json['isCompleted']),
      isVoid: _bool(json['isVoid']),
      isRead: _bool(json['isRead']),
      isDirect: _bool(json['isDirect']),
      radius: _num(json['radius']),
      updatePilotRate: _num(json['updatePilotRate']),
      updateSICRate: _num(json['updateSICRate']),
      updateAttendantRate: _num(json['updateAttendantRate']),
      updateInstructorRate: _num(json['updateInstructorRate']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}

class OwnerTripDetailResponse {
  final OwnerTripDetailModel trip;
  final List<TripCrewMemberModel> crewList;

  OwnerTripDetailResponse({
    required this.trip,
    required this.crewList,
  });

  factory OwnerTripDetailResponse.fromJson(Map<String, dynamic> json) {
    final tripJson = (json['trip'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final crewArr = (json['crewList'] as List?) ?? const [];

    return OwnerTripDetailResponse(
      trip: OwnerTripDetailModel.fromJson(tripJson),
      crewList: crewArr
          .whereType<Map>()
          .map((e) => TripCrewMemberModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}