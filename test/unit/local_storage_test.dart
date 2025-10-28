import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_flutter/core/storage/local_storage.dart';

void main() {
  group('Local Storage Tests', () {
    late LocalStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await SharedPreferencesStorage.getInstance();
    });

    test('should save and retrieve string', () async {
      const key = 'test_string';
      const value = 'test value';

      await storage.saveString(key, value);
      final result = await storage.getString(key);

      expect(result, value);
    });

    test('should save and retrieve int', () async {
      const key = 'test_int';
      const value = 42;

      await storage.saveInt(key, value);
      final result = await storage.getInt(key);

      expect(result, value);
    });

    test('should save and retrieve bool', () async {
      const key = 'test_bool';
      const value = true;

      await storage.saveBool(key, value);
      final result = await storage.getBool(key);

      expect(result, value);
    });

    test('should save and retrieve JSON', () async {
      const key = 'test_json';
      final value = {'name': 'test', 'count': 10, 'active': true};

      await storage.saveJson(key, value);
      final result = await storage.getJson(key);

      expect(result, value);
    });

    test('should save and retrieve JSON list', () async {
      const key = 'test_json_list';
      final value = [
        {'id': '1', 'name': 'Item 1'},
        {'id': '2', 'name': 'Item 2'},
      ];

      await storage.saveJsonList(key, value);
      final result = await storage.getJsonList(key);

      expect(result, value);
    });

    test('should return null for non-existent key', () async {
      final result = await storage.getString('non_existent_key');
      expect(result, isNull);
    });

    test('should return null for malformed JSON', () async {
      const key = 'malformed_json';
      
      // Save malformed JSON directly through SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, 'invalid json');
      
      final result = await storage.getJson(key);
      expect(result, isNull);
    });

    test('should remove key', () async {
      const key = 'test_remove';
      const value = 'to be removed';

      await storage.saveString(key, value);
      expect(await storage.getString(key), value);

      await storage.remove(key);
      expect(await storage.getString(key), isNull);
    });

    test('should clear all data', () async {
      await storage.saveString('key1', 'value1');
      await storage.saveInt('key2', 42);
      await storage.saveBool('key3', true);

      await storage.clear();

      expect(await storage.getString('key1'), isNull);
      expect(await storage.getInt('key2'), isNull);
      expect(await storage.getBool('key3'), isNull);
    });

    test('should handle empty JSON list', () async {
      const key = 'empty_list';
      final value = <Map<String, dynamic>>[];

      await storage.saveJsonList(key, value);
      final result = await storage.getJsonList(key);

      expect(result, isEmpty);
    });
  });
}