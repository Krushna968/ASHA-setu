import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String tokenKey = 'jwt_token';
  static const String workerNameKey = 'worker_name';
  static const String workerIdKey = 'worker_id';

  // Save the authentication token and user details locally
  static Future<void> saveAuthData(String token, Map<String, dynamic> workerData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(workerNameKey, workerData['name'] ?? '');
    await prefs.setString(workerIdKey, workerData['id'] ?? '');
  }

  // Get the locally saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<String?> getWorkerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(workerNameKey);
  }

  static Future<String?> getWorkerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(workerIdKey);
  }

  // Check if user is already logged in (has valid token)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Skip language screen if already selected
  static const String languageSelectedKey = 'language_selected';

  static Future<void> setLanguageSelected() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(languageSelectedKey, true);
  }

  static Future<bool> isLanguageSelected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(languageSelectedKey) ?? false;
  }

  // Clearauth data on logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(workerNameKey);
    await prefs.remove(workerIdKey);
  }
}
