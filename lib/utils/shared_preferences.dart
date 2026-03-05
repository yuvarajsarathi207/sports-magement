import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static SharedPreferences? _preferences;

  /// Initialize SharedPreferences
  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Save String
  static Future setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  static Future<void> setCustom(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  static Future<String?> getCustom(String key) async {
    return _preferences?.getString(key);
  }
  /// Get String
  static String? getString(String key) {
    return _preferences?.getString(key);
  }

  /// Save Bool
  static Future setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  /// Get Bool
  static bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  /// Save Int
  static Future setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  /// Get Int
  static int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  /// Remove Key
  static Future remove(String key) async {
    await _preferences?.remove(key);
  }

  /// Clear All
  static Future clear() async {
    await _preferences?.clear();
  }
}