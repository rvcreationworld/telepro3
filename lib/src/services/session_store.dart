import 'package:shared_preferences/shared_preferences.dart';

abstract final class SessionStore {
  static const _tokenKey = 'auth_token';

  static Future<void> saveAuthToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
  }

  static Future<String?> authToken() async {
    const configuredToken = String.fromEnvironment('AUTH_TOKEN');
    if (configuredToken.isNotEmpty) return configuredToken;
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_tokenKey);
  }
}
