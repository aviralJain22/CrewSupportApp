/// Global constants for membership / profile types
class MembershipType {
  static const int ownerOperator = 1;
  static const int instructor = 2;
  static const int pilot = 3;
  static const int flightAttendant = 4;

  /// Optional labels
  static const String ownerLabel = "Owner/Operator";
  static const String instructorLabel = "Instructor";
  static const String pilotLabel = "Pilot";
  static const String attendantLabel = "Flight Attendant";

  /// Map if you ever need both ID + Label together
  static const Map<int, String> typeLabels = {
    ownerOperator: ownerLabel,
    instructor: instructorLabel,
    pilot: pilotLabel,
    flightAttendant: attendantLabel,
  };
}

  /// Helper: convert numeric membershipType into human-readable label.
  String membershipLabelFromType(int? membershipType) {
    switch (membershipType) {
      case 1:
        return 'Owner/Operator';
      case 2:
        return 'Instructor';
      case 3:
        return 'Pilot';
      case 4:
        return 'Flight Attendant';
      case 5:
        return 'SIC';
      default:
        return '';
    }
  }
