import 'package:shared_preferences/shared_preferences.dart';

enum LocalStorageKey { videoVolumeSetting }

class CMSharedPreference {
  static late SharedPreferences _preferences;

  static Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<bool> setStringList(LocalStorageKey key, List<String> value) {
    return _preferences.setStringList(key.name, value);
  }

  static List<String>? getStringList(LocalStorageKey key) {
    return _preferences.getStringList(key.name);
  }

  static Future<bool> setBool(LocalStorageKey key, bool value) {
    return _preferences.setBool(key.name, value);
  }

  static bool getBool(LocalStorageKey key) {
    return _preferences.getBool(key.name) ?? false;
  }
}
