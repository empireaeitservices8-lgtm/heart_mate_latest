import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyIsLogged = 'is_logged';
  static const String _keyFcmToken = 'fcm_token';

  // Save FCM token
  Future<bool> saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyFcmToken, token);
  }

  // Get FCM token
  Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFcmToken);
  }

  // Save token
  Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyToken, token);
  }

  // Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Save isLoggedIn status
  Future<bool> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyIsLogged, isLoggedIn);
  }

  // Get isLoggedIn status
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLogged) ?? false;
  }

  // Clear token & login status
  Future<bool> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLogged);
    return await prefs.remove(_keyToken);
  }
}
