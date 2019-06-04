import 'dart:async';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of `HydratedBlocStorage` which uses `SharedPreferences`
/// to persist and retrieve state changes from the local device.
class HydratedSharedPreferences implements HydratedBlocStorage {
  SharedPreferences _preferences;

  static HydratedSharedPreferences _instance;

  static Future<HydratedSharedPreferences> getInstance() async {
    if (_instance != null) {
      return _instance;
    }
    final preferences = await SharedPreferences.getInstance();
    _instance = HydratedSharedPreferences._(preferences);
    return _instance;
  }

  HydratedSharedPreferences._(this._preferences);

  @override
  String read(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<void> write(String key, String value) {
    return _preferences.setString(key, value);
  }

  @override
  Future<void> clear() async {
    return await _preferences.clear();
  }
}
