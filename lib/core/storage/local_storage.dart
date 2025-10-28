import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveInt(String key, int value);
  Future<int?> getInt(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> saveDouble(String key, double value);
  Future<double?> getDouble(String key);
  Future<void> saveJson(String key, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> getJson(String key);
  Future<void> saveJsonList(String key, List<Map<String, dynamic>> jsonList);
  Future<List<Map<String, dynamic>>?> getJsonList(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

class SharedPreferencesStorage implements LocalStorage {
  static SharedPreferencesStorage? _instance;
  static SharedPreferences? _prefs;

  SharedPreferencesStorage._();

  static Future<SharedPreferencesStorage> getInstance() async {
    if (_instance == null) {
      _instance = SharedPreferencesStorage._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _prefs!.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs!.getString(key);
  }

  @override
  Future<void> saveInt(String key, int value) async {
    await _prefs!.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs!.getInt(key);
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    await _prefs!.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs!.getBool(key);
  }

  @override
  Future<void> saveDouble(String key, double value) async {
    await _prefs!.setDouble(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    return _prefs!.getDouble(key);
  }

  @override
  Future<void> saveJson(String key, Map<String, dynamic> json) async {
    final jsonString = jsonEncode(json);
    await _prefs!.setString(key, jsonString);
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveJsonList(String key, List<Map<String, dynamic>> jsonList) async {
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString(key, jsonString);
  }

  @override
  Future<List<Map<String, dynamic>>?> getJsonList(String key) async {
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> remove(String key) async {
    await _prefs!.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs!.clear();
  }
}