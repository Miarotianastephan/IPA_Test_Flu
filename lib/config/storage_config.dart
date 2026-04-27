import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService instance = StorageService._internal();

  late final SharedPreferences _prefs;

  StorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setValue<T>(String key, T value) async {
    switch (value) {
      case String():
        await _prefs.setString(key, value);
      case int():
        await _prefs.setInt(key, value);
      case double():
        await _prefs.setDouble(key, value);
      case bool():
        await _prefs.setBool(key, value);
      case List<String>():
        await _prefs.setStringList(key, value);
      default:
        await _prefs.setString(key, value.toString());
    }
  }

  T? getValue<T>(String key) {
    return switch (T) {
      const (String) => _prefs.getString(key) as T?,
      const (int) => _prefs.getInt(key) as T?,
      const (double) => _prefs.getDouble(key) as T?,
      const (bool) => _prefs.getBool(key) as T?,
      const (List<String>) => _prefs.getStringList(key) as T?,
      _ => _prefs.get(key) as T?,
    };
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> removeMultiple(List<String> keys) async {
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  Future<void> clearUserData() async {
    final userDataKeys = ['token', 'user_info'];
    await removeMultiple(userDataKeys);
  }

  Future<void> clearAll() async {
    final keysToPreserve = [
      'app_instance_id',
      'first_open_sent',
      'search_history',
    ];

    final Map<String, dynamic> preservedData = {};
    for (final key in keysToPreserve) {
      final value = _prefs.get(key);
      if (value != null) {
        preservedData[key] = value;
      }
    }

    await _prefs.clear();

    for (final entry in preservedData.entries) {
      final key = entry.key;
      final value = entry.value;

      switch (value) {
        case String():
          await _prefs.setString(key, value);
        case int():
          await _prefs.setInt(key, value);
        case double():
          await _prefs.setDouble(key, value);
        case bool():
          await _prefs.setBool(key, value);
        case List<String>():
          await _prefs.setStringList(key, value);
      }
    }
  }

  Future<void> clearEverything() async {
    await _prefs.clear();
  }

  String? _sanitizeToken(String? token) {
    if (token == null) return null;
    final trimmed = token.trim();
    if (trimmed.isEmpty || trimmed == 'null' || trimmed == 'undefined') {
      return null;
    }
    return trimmed;
  }

  bool get isLoggedIn {
    return userToken != null;
  }

  String? get userToken => _sanitizeToken(getValue<String>('token'));

  String? get userInfoJson => getValue<String>('user_info');

  Future<void> deleteDatabaseForUser(String userId) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final dbFile = File('${dir.path}/chat_user_$userId.sqlite');

      if (await dbFile.exists()) {
        await dbFile.delete();
      }

      final walFile = File('${dir.path}/chat_user_$userId.sqlite-wal');
      if (await walFile.exists()) await walFile.delete();

      final shmFile = File('${dir.path}/chat_user_$userId.sqlite-shm');
      if (await shmFile.exists()) await shmFile.delete();
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
    }
  }
}
