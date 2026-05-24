// FlatUserProfileSafe.dart
// A safe, null-tolerant wrapper around the flat map returned by getFlatUserProfile_v2.
// Includes typed getters for String/int/double/bool/DateTime and convenience accessors
// for common _User fields we merged in the CF.

// You can keep this file in your project and use it immediately.

class FlatUserProfileSafe {
  /// The raw flat JSON returned by the Cloud Function.
  final Map<String, dynamic> data;

  FlatUserProfileSafe(this.data);

  // -----------------------
  // Basic typed accessors
  // -----------------------

  /// Generic safe getter for any key.
  T? get<T>(String key) {
    final v = data[key];
    if (v == null) return null;
    // If the expected type matches, return as-is
    if (v is T) return v;

    // Do some flexible conversions that commonly occur with Parse JSON
    if (T == String) return _asString(v) as T?;
    if (T == int) return _asInt(v) as T?;
    if (T == double) return _asDouble(v) as T?;
    if (T == bool) return _asBool(v) as T?;
    if (T == DateTime) return _asDateTime(v) as T?;

    // Otherwise give up gracefully
    return null;
  }

  String? getString(String key) => get<String>(key);
  int? getInt(String key) => get<int>(key);
  double? getDouble(String key) => get<double>(key);
  bool? getBool(String key) => get<bool>(key);
  DateTime? getDate(String key) => get<DateTime>(key);

  // -----------------------
  // Common convenience keys
  // (These exist because the CF adds them at top-level)
  // -----------------------

  String get userId => data['userId'] as String? ?? '';
  String get profileId => data['profileId'] as String? ?? '';

  String? get firstName => getString('firstName');           // from _User
  String? get lastName => getString('lastName');             // from _User
  String? get fullName => getString('fullName');             // from _User
  String? get email => getString('email');                   // from _User
  String? get username => getString('username');             // from _User
  int? get membershipType => getInt('membershipType');       // from _User
  String? get countryName => getString('countryName');       // from _User
  String? get countryCode => getString('countryCode');       // from _User
  String? get dialCode => getString('dialCode');             // from _User
  int? get gender => getInt('gender');                       // from _User
  String? get userPhoneNumber => getString('userPhoneNumber'); // _User.phoneNumber (renamed)

  /// Profile timestamps (top-level ISO strings) with parsing helpers:
  String? get profileCreatedAtIso => getString('profileCreatedAt');
  String? get profileUpdatedAtIso => getString('profileUpdatedAt');
  DateTime? get profileCreatedAt => getDate('profileCreatedAt');
  DateTime? get profileUpdatedAt => getDate('profileUpdatedAt');

  // -----------------------
  // Example per-column convenience (optional)
  // Add these as you like for frequently-used fields in your UI.
  // Keeping it minimal to avoid guessing your full schema list.
  // -----------------------

  String? get profilePhoneNumber => getString('phoneNumber');  // profile.phoneNumber
  int? get oldPkPilotId => getInt('oldPkPilotId');

  // If your schema has dates like 'FAAMedicalDate' or 'PassportExpDate':
  // DateTime? get faaMedicalDate => getDate('FAAMedicalDate');
  // DateTime? get passportExpDate => getDate('PassportExpDate');

  // -----------------------
  // Internal conversion helpers
  // -----------------------

  String? _asString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
    // For Parse Dates you usually already get an ISO string.
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      return int.tryParse(s);
    }
    return null;
  }

  double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      return double.tryParse(s);
    }
    return null;
  }

  bool? _asBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase().trim();
      if (['true', 'yes', '1'].contains(s)) return true;
      if (['false', 'no', '0'].contains(s)) return false;
    }
    return null;
  }

  DateTime? _asDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) {
      // Parse ISO-8601 from Parse toJSON (e.g. "2025-10-29T12:34:56.000Z")
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}