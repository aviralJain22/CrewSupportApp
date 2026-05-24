import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AuthRepo {
  Future<ParseUser?> login(String email, String password) async {
    final user = ParseUser(email.trim(), password, email.trim());
    final res = await user.login();
    if (res.success && res.result is ParseUser) {
      return res.result as ParseUser;
    }
    throw Exception(res.error?.message ?? 'Login failed');
  }

  Future<ParseUser?> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final user = ParseUser(email.trim(), password, email.trim());
    if (fullName != null && fullName.trim().isNotEmpty) {
      user.set<String>('fullName', fullName.trim());
    }
    final res = await user.signUp();
    if (res.success && res.result is ParseUser) {
      return res.result as ParseUser;
    }
    throw Exception(res.error?.message ?? 'Registration failed');
  }

  Future<void> requestPasswordReset(String email) async {
    final ParseUser user = ParseUser(null, null, email.trim());
    final res = await user.requestPasswordReset();
    if (!res.success) {
      throw Exception(res.error?.message ?? 'Password reset failed');
    }
  }

  Future<void> logout() async {
    final current = await ParseUser.currentUser();
    if (current is ParseUser) {
      await current.logout();
    }
  }

  Future<ParseUser?> currentUser() async {
    final current = await ParseUser.currentUser();
    return current is ParseUser ? current : null;
  }
}