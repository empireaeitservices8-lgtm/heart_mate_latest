import 'package:shared_preferences/shared_preferences.dart';

class SpHelper {
  SpHelper._();

  static const String keyToken = 'auth_token';
  static const String _keyIsLogged = 'is_logged';
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyLanguage = 'app_language';

  // Generic getter helper
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<bool> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  // ---------------- Token & Authentication ----------------
  static Future<bool> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyToken);
  }

  static Future<bool> setIsLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_keyIsLogged, isLoggedIn);
  }

  static Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLogged) ?? false;
  }

  // ---------------- User Session ----------------
  static Future<bool> setUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setInt(_keyUserId, id);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  static Future<bool> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyUsername, username);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  // ---------------- FCM Push Notifications ----------------
  static Future<bool> setFcmToken(String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyFcmToken, fcmToken);
  }

  static Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFcmToken);
  }

  // ---------------- Theme & Language ----------------
  static Future<bool> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyThemeMode, mode);
  }

  static Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode);
  }

  static Future<bool> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyLanguage, langCode);
  }

  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  static const String keyIsAgent = 'is_agent_mode';

  // ---------------- Agent Mode ----------------
  static Future<bool> setIsAgent(bool isAgent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_agent', isAgent);
    return prefs.setBool(keyIsAgent, isAgent);
  }

  static Future<bool> getIsAgent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsAgent) ?? prefs.getBool('is_agent') ?? false;
  }

  // ---------------- Clear / Logout ----------------
  static Future<bool> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyToken);
    await prefs.remove(_keyIsLogged);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(keyIsAgent);
    await prefs.remove('is_agent');
    await prefs.remove('agent_status');
    await prefs.remove('agent_registration_data');
    await prefs.remove('agent_registration_date');
    await prefs.remove('wallet_transactions');
    await prefs.remove('agent_withdrawals');
    return true;
  }

  static Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
