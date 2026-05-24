class ConnectionProfile {
  String connectionId;
  String status;
  String direction;

  String otherUserId;
  String otherProfileId;
  dynamic otherProfileType;

  String fullName;
  String firstName;
  String lastName;
  String photoPath;

  bool isAccepted;

  ConnectionProfile({
    required this.connectionId,
    required this.status,
    required this.direction,
    required this.otherUserId,
    required this.otherProfileId,
    required this.otherProfileType,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.photoPath,
    required this.isAccepted,
  });

  factory ConnectionProfile.fromMap(
    Map<String, dynamic> data, {
    required bool isAccepted,
  }) {
    final firstName = (data['firstName'] ?? '').toString();
    final lastName = (data['lastName'] ?? '').toString();

    return ConnectionProfile(
      connectionId:
          (data['connectionId'] ?? data['objectId'] ?? '').toString(),

      status: (data['status'] ?? '').toString(),
      direction: (data['direction'] ?? '').toString(),

      otherUserId: (data['otherUserId'] ?? '').toString(),
      otherProfileId: (data['otherProfileId'] ?? '').toString(),
      otherProfileType: data['otherProfileType'],

      fullName: (data['fullName'] ?? '').toString().trim().isNotEmpty
          ? (data['fullName'] ?? '').toString()
          : '$firstName $lastName'.trim(),

      firstName: firstName,
      lastName: lastName,

      photoPath: (data['photoPath'] ?? '').toString(),

      isAccepted: isAccepted,
    );
  }
}