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

  bool get isLoggedIn {
    final token = getValue<String>('token');
    return token != null && token.isNotEmpty;
  }

  String? get userToken => getValue<String>('token');

  String? get userInfoJson => getValue<String>('user_info');
}
