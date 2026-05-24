class TripDraftPayload {
  String? tripObjectId; // Parse objectId

  // Trip class fields
  int? departureSourceId;
  int? destinationSourceId;
  List<int> enrouteSourceIds;

  String? tripName;
  DateTime? startDate;
  DateTime? endDate;
  int? aircraftId;
  String? aircraftName;
  int? radius;

  // Rate fields (used by createTrip cloud function)
  num? pilotRate;
  num? sicRate;
  num? attendantRate;
  num? instructorRate;

  // Role flags (used by createTrip cloud function)
  bool? isCaptain;
  bool? isSIC;
  bool? isAttendant;
  bool? isInstructor;

  // Trip status flags (used by createTrip cloud function)
  bool isStarted;
  bool isCompleted;
  bool isVoid;
  bool isRead;
  bool isDirect;

  // Role-based requirements (store as JSON Map so it can be saved as a file later)
  Map<String, dynamic> roleRequirements;

  TripDraftPayload({
    this.tripObjectId,
    this.departureSourceId,
    this.destinationSourceId,
    List<int>? enrouteSourceIds,
    this.tripName,
    this.startDate,
    this.endDate,
    this.aircraftId,
    this.aircraftName,
    this.radius,

    // Rate fields
    this.pilotRate,
    this.sicRate,
    this.attendantRate,
    this.instructorRate,

    // Role flags
    this.isCaptain,
    this.isSIC,
    this.isAttendant,
    this.isInstructor,

    // Status flags (default false like controller)
    bool? isStarted,
    bool? isCompleted,
    bool? isVoid,
    bool? isRead,
    bool? isDirect,

    Map<String, dynamic>? roleRequirements,
  })  : enrouteSourceIds = enrouteSourceIds ?? <int>[],
        isStarted = isStarted ?? false,
        isCompleted = isCompleted ?? false,
        isVoid = isVoid ?? false,
        isRead = isRead ?? false,
        isDirect = isDirect ?? false,
        roleRequirements = roleRequirements ?? <String, dynamic>{};

  // Make updates easy without mutating original
  TripDraftPayload copyWith({
    String? tripObjectId,
    int? departureSourceId,
    int? destinationSourceId,
    List<int>? enrouteSourceIds,
    String? tripName,
    DateTime? startDate,
    DateTime? endDate,
    int? aircraftId,
    String? aircraftName,
    int? radius,
    num? pilotRate,
    num? sicRate,
    num? attendantRate,
    num? instructorRate,
    bool? isCaptain,
    bool? isSIC,
    bool? isAttendant,
    bool? isInstructor,
    bool? isStarted,
    bool? isCompleted,
    bool? isVoid,
    bool? isRead,
    bool? isDirect,
    Map<String, dynamic>? roleRequirements,
  }) {
    return TripDraftPayload(
      tripObjectId: tripObjectId ?? this.tripObjectId,
      departureSourceId: departureSourceId ?? this.departureSourceId,
      destinationSourceId: destinationSourceId ?? this.destinationSourceId,
      enrouteSourceIds: enrouteSourceIds ?? List<int>.from(this.enrouteSourceIds),
      tripName: tripName ?? this.tripName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      aircraftId: aircraftId ?? this.aircraftId,
      aircraftName: aircraftName ?? this.aircraftName,
      radius: radius ?? this.radius,
      pilotRate: pilotRate ?? this.pilotRate,
      sicRate: sicRate ?? this.sicRate,
      attendantRate: attendantRate ?? this.attendantRate,
      instructorRate: instructorRate ?? this.instructorRate,
      isCaptain: isCaptain ?? this.isCaptain,
      isSIC: isSIC ?? this.isSIC,
      isAttendant: isAttendant ?? this.isAttendant,
      isInstructor: isInstructor ?? this.isInstructor,
      isStarted: isStarted ?? this.isStarted,
      isCompleted: isCompleted ?? this.isCompleted,
      isVoid: isVoid ?? this.isVoid,
      isRead: isRead ?? this.isRead,
      isDirect: isDirect ?? this.isDirect,
      roleRequirements: roleRequirements ?? Map<String, dynamic>.from(this.roleRequirements),
    );
  }

  Map<String, dynamic> toJson() => {
        'tripObjectId': tripObjectId,
        'departureSourceId': departureSourceId,
        'destinationSourceId': destinationSourceId,
        'enrouteSourceIds': enrouteSourceIds,
        'tripName': tripName,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'aircraftId': aircraftId,
        'aircraftName': aircraftName,
        'radius': radius,
        'pilotRate': pilotRate,
        'sicRate': sicRate,
        'attendantRate': attendantRate,
        'instructorRate': instructorRate,
        'isCaptain': isCaptain,
        'isSIC': isSIC,
        'isAttendant': isAttendant,
        'isInstructor': isInstructor,
        'isStarted': isStarted,
        'isCompleted': isCompleted,
        'isVoid': isVoid,
        'isRead': isRead,
        'isDirect': isDirect,
        'roleRequirements': roleRequirements,
      };

  static TripDraftPayload fromJson(Map<String, dynamic> json) {
    return TripDraftPayload(
      tripObjectId: json['tripObjectId']?.toString(),
      departureSourceId: json['departureSourceId'],
      destinationSourceId: json['destinationSourceId'],
      enrouteSourceIds: (json['enrouteSourceIds'] as List?)?.cast<int>() ?? <int>[],
      tripName: json['tripName'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      aircraftId: json['aircraftId'],
      aircraftName: json['aircraftName'],
      radius: json['radius'],
      pilotRate: json['pilotRate'],
      sicRate: json['sicRate'],
      attendantRate: json['attendantRate'],
      instructorRate: json['instructorRate'],
      isCaptain: json['isCaptain'],
      isSIC: json['isSIC'],
      isAttendant: json['isAttendant'],
      isInstructor: json['isInstructor'],
      isStarted: json['isStarted'],
      isCompleted: json['isCompleted'],
      isVoid: json['isVoid'],
      isRead: json['isRead'],
      isDirect: json['isDirect'],
      roleRequirements: (json['roleRequirements'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
    );
  }
}