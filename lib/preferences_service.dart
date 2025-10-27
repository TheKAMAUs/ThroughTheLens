import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeModeKey = 'themeMode';
  static const String _userTokenKey = 'userToken';
  static const String _checkoutId = 'checkoutId';
  static const String _uId = 'uid';

  /// Save theme mode (true = dark, false = light)
  Future<void> setThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, isDarkMode);
  }

  /// Get theme mode
  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeModeKey) ?? false;
  }

  /// Save user token
  Future<void> setUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTokenKey, token);
  }

  /// Get user token
  Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTokenKey);
  }

  /// Save user token
  Future<void> setcheckoutId(String checkoutId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkoutId, checkoutId);

    // ✅ Print to confirm it's stored
    print("💾 Checkout ID saved locally: $checkoutId");
  }

  /// Get user token
  Future<String?> getcheckoutId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_checkoutId);
  }

  /// Clear all stored preferences
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Create a single instance of FlutterSecureStorage
  static final _storage = const FlutterSecureStorage();

  /// 🔹 Save a value securely
  static Future<void> saveUid(String uid) async {
    try {
      await _storage.write(key: _uId, value: uid);
      print('[SecureStorage] UID saved successfully');
    } catch (e) {
      print('[SecureStorage] Error saving UID: $e');
    }
  }

  /// 🔹 Get the saved UID
  static Future<String?> getUid() async {
    try {
      final uid = await _storage.read(key: _uId);
      print('[SecureStorage] Retrieved UID: $uid');
      return uid;
    } catch (e) {
      print('[SecureStorage] Error reading UID: $e');
      return null;
    }
  }

  /// 🔹 Delete the stored UID (useful for logout)
  static Future<void> clearUid() async {
    try {
      await _storage.delete(key: _uId);
      print('[SecureStorage] UID cleared');
    } catch (e) {
      print('[SecureStorage] Error clearing UID: $e');
    }
  }
}
