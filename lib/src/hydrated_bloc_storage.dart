import 'dart:async';

/// Interface which `HydratedBlocDelegate` uses to persist and retrieve
/// state changes from the local device.
abstract class HydratedBlocStorage {
  String read(String key);
  void write(String key, String value);
  Future<void> clear();
}
