import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../../../../core/network/appwrite_client.dart';

class AuthRepository {
  final Account _account;

  AuthRepository() : _account = Account(client);

  Future<models.User?> getCurrentUser() async {
    try {
      return await _account.get();
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        return null; // Not logged in
      }
      rethrow;
    }
  }

  Future<models.Session> login(String email, String password) async {
    try {
      return await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } on AppwriteException catch (e) {
      if (e.type == 'user_session_already_exists') {
        // If session exists, we first log out to ensure fresh session with provided credentials
        try {
          await logout();
        } catch (_) {}
        return await _account.createEmailPasswordSession(
          email: email,
          password: password,
        );
      }
      rethrow;
    }
  }

  Future<models.User> register(
    String email,
    String password,
    String name,
  ) async {
    return await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }

  Future<void> updatePreferences(Map<String, dynamic> prefs) async {
    await _account.updatePrefs(prefs: prefs);
  }

  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
  }
}
