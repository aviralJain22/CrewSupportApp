/// Model representing one pilot row from getPilotList cloud function.
class CrewListItem {
  /// pilotProfile objectId
  final String id;

  /// Associated _User objectId (may be empty if not provided)
  final String userId;

  /// Pilot's first name
  final String firstName;

  /// Pilot's last name
  final String lastName;

  /// URL of profile picture (may be empty string if not set)
  final String profilePictureUrl;

  /// State (string field in pilotProfile)
  final String state;

  /// City (string field in pilotProfile)
  final String city;

  CrewListItem({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.profilePictureUrl,
    required this.state,
    required this.city,
  });

  /// Convenience getter to show "First Last"
  String get fullName {
    final parts = <String>[];
    if (firstName.trim().isNotEmpty) parts.add(firstName.trim());
    if (lastName.trim().isNotEmpty) parts.add(lastName.trim());
    return parts.join(' ');
  }

  /// Factory to build from JSON returned by cloud function.
  ///
  /// Expected shape from getPilotList:
  /// {
  ///   "objectId": "xxxx",
  ///   "userObjectId": "xxxx",
  ///   "firstName": "John",
  ///   "lastName": "Doe",
  ///   "profilePicture": "https://...",
  ///   "State": "Texas",
  ///   "City": "Dallas"
  /// }
  factory CrewListItem.fromJson(Map<String, dynamic> json) {
    return CrewListItem(
      id: (json['objectId'] ?? '').toString(),
      userId: (json['userObjectId'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      profilePictureUrl: (json['profilePicture'] ?? '').toString(),
      state: (json['State'] ?? '').toString(),
      city: (json['City'] ?? '').toString(),
    );
  }
}