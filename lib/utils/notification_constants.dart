/// Notification type constants used across the app.
abstract class NotificationType {
  static const int tripRequestSent = 17;
  static const int crewAcceptedTrip = 5;
  static const int ownerApprovedCrewAcceptance = 1;
  static const int crewNegotiates = 2;
  static const int ownerNegotiates = 4;
  static const int crewRequestsTripCancellation = 15;
  static const int ownerRequestsTripCancellation = 16;
  static const int tripCompleted = 3;
}