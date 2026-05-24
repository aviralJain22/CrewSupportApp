class TripNotification {
  /// Parse `objectId` of the tripNotification row
  final String objectId;
  /// Notification message text
  final String text;
  /// `createdAt` from Parse
  final DateTime date;
  /// Parse `updatedAt`
  final DateTime updatedAt;
  /// Membership type (e.g. 3 = Pilot, 5 = SIC)
  final int? membershipType;
  /// Notification type
  final int? type;
  /// Optional amount associated with this notification
  final double? amount;
  /// Read flags
  final bool isOwnerRead;
  final bool isCrewRead;
  /// NEW: Whether this notification has been responded to
  final bool responded;


  TripNotification({
    required this.objectId,
    required this.text,
    required this.date,
    required this.updatedAt,
    required this.membershipType,
    required this.type,
    required this.amount,
    required this.isOwnerRead,
    required this.isCrewRead,
    required this.responded,
  });

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

  factory TripNotification.fromJson(Map<String, dynamic> json) {
    final rawId = json['objectId'];
    final rawText = json['message'] ?? json['text'];

    final createdAt =
        _parseParseDate(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0);
    final updatedAt =
        _parseParseDate(json['updatedAt']) ?? createdAt;

    return TripNotification(
      objectId: rawId?.toString() ?? '',
      text: rawText?.toString() ?? '',
      date: createdAt,
      updatedAt: updatedAt,
      membershipType: json['membershipType'] is int
          ? json['membershipType'] as int
          : int.tryParse(json['membershipType']?.toString() ?? ''),
      type: json['type'] is int
          ? json['type'] as int
          : int.tryParse(json['type']?.toString() ?? ''),
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? ''),
      isOwnerRead: json['isOwnerRead'] == true,
      isCrewRead: json['isCrewRead'] == true,
      responded: json['responded'] == true,
    );
  }
}