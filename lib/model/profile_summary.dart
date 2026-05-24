/// Simple model to hold the basic profile info
class ProfileSummary {
  final int membershipType;
  final String firstName;
  final String lastName;
  final String photoPath;
  final bool isDisabled; // NEW
  final bool currentLocation; // NEW
  final String objectId;

  ProfileSummary({
    required this.membershipType,
    required this.firstName,
    required this.lastName,
    required this.photoPath,
    required this.isDisabled,
    required this.currentLocation,
    required this.objectId,
  });

  /// Factory to build from Map returned by Cloud Function
  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    return ProfileSummary(
      membershipType: json['membershipType'] as int? ?? 0,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      photoPath: json['photoPath'] as String? ?? '',
      // If API doesn't send isDisabled, default to false
      isDisabled: json['isDisabled'] == true,
      currentLocation: json['currentLocation'] == true,
      objectId: json['objectId'] as String? ?? '',
    );
  }
}