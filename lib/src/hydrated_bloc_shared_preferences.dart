import 'dart:async';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of `HydratedBlocStorage` which uses `SharedPreferences`
/// to persist and retrieve state changes from the local device.
class HydratedBlocSharedPreferences implements HydratedBlocStorage {
  SharedPreferences _prefs;

  static HydratedBlocSharedPreferences _instance;

  static Future<HydratedBlocSharedPreferences> getInstance() async {
    if (_instance != null) {
      return _instance;
    }
    final prefs = await SharedPreferences.getInstance();
    _instance = HydratedBlocSharedPreferences._(prefs);
    return _instance;
  }

  HydratedBlocSharedPreferences._(this._prefs);

  @override
  String read(String key) {
    return _prefs.getString(key);
  }

  @override
  void write(String key, String value) {
    _prefs.setString(key, value);
  }
}
