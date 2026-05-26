import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  UserSession._();
  static final instance = UserSession._();

  static const _keyRole      = 'cs_user_role';
  static const _keyFirstName = 'cs_first_name';
  static const _keyLastName  = 'cs_last_name';

  String _role      = 'Owner';
  String _firstName = '';
  String _lastName  = '';

  String get role       => _role;
  String get firstName  => _firstName;
  String get lastName   => _lastName;

  String get displayName {
    final full = '$_firstName $_lastName'.trim();
    return full.isNotEmpty ? full : 'Crew Member';
  }

  String get initials {
    final f = _firstName.isNotEmpty ? _firstName[0] : '';
    final l = _lastName.isNotEmpty  ? _lastName[0]  : '';
    final combined = (f + l).toUpperCase();
    return combined.isNotEmpty ? combined : 'CS';
  }

  bool get isOwner           => _role == 'Owner';
  bool get isPilot           => _role == 'Pilot / Captain';
  bool get isFlightAttendant => _role == 'Flight Attendant';

  Future<void> save({
    required String role,
    required String firstName,
    required String lastName,
  }) async {
    _role      = role;
    _firstName = firstName;
    _lastName  = lastName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyFirstName, firstName);
    await prefs.setString(_keyLastName, lastName);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _role      = prefs.getString(_keyRole)      ?? 'Owner';
    _firstName = prefs.getString(_keyFirstName) ?? '';
    _lastName  = prefs.getString(_keyLastName)  ?? '';
  }

  Future<void> clear() async {
    _role = 'Owner'; _firstName = ''; _lastName = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRole);
    await prefs.remove(_keyFirstName);
    await prefs.remove(_keyLastName);
  }
}
