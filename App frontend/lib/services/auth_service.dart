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

  // Check if user is already logged in (has valid token)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Clearauth data on logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(workerNameKey);
    await prefs.remove(workerIdKey);
  }
}
