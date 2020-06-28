import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

import 'hydrated_cipher.dart';

/// Interface which `HydratedCubitDelegate` uses to persist and retrieve
/// state changes from the local device.
abstract class HydratedStorage {
  /// Returns value for key
  dynamic read(String key);

  /// Persists key value pair
  Future<void> write(String key, dynamic value);

  /// Deletes key value pair
  Future<void> delete(String key);

  /// Clears all key value pairs from storage
  Future<void> clear();
}

/// {@template hydrated_cubit_storage}
/// Implementation of [HydratedStorage] which uses `PathProvider` and `dart.io`
/// to persist and retrieve state changes from the local device.
/// {@endtemplate}
class HydratedCubitStorage extends HydratedStorage {
  /// {@macro hydrated_cubit_storage}
  @visibleForTesting
  HydratedCubitStorage(this._box);

  /// Returns an instance of `HydratedCubitStorage`.
  /// [storageDirectory] can optionally be provided.
  /// By default, `getTemporaryDirectory` is used.
  ///
  /// With [encryptionCipher] you can provide custom encryption.
  /// Following snippet shows how to make default one:
  /// ```dart
  /// import 'package:crypto/crypto.dart';
  /// import 'package:hydrated_cubit/hydrated_cubit.dart';
  ///
  /// const password = 'hydration';
  /// final byteskey = sha256.convert(utf8.encode(password)).bytes;
  /// return HydratedAesCipher(byteskey);
  /// ```
  static Future<HydratedStorage> getInstance({
    Directory storageDirectory,
    HydratedCipher encryptionCipher,
  }) {
    return _lock.synchronized(() async {
      if (_instance != null) return _instance;
      final directory = storageDirectory ?? await getTemporaryDirectory();
      if (!kIsWeb) Hive.init(directory.path);
      final box = await Hive.openBox<dynamic>(
        'hydrated_box',
        encryptionCipher: encryptionCipher,
      );
      return _instance = HydratedCubitStorage(box);
    });
  }

  static final _lock = Lock();
  static HydratedStorage _instance;

  final Box _box;

  @override
  dynamic read(String key) => _box.isOpen ? _box.get(key) : null;

  @override
  Future<void> write(String key, dynamic value) {
    if (_box.isOpen) {
      return _lock.synchronized(() => _box.put(key, value));
    }
    return null;
  }

  @override
  Future<void> delete(String key) {
    if (_box.isOpen) {
      return _lock.synchronized(() => _box.delete(key));
    }
    return null;
  }

  @override
  Future<void> clear() {
    if (_box.isOpen) {
      _instance = null;
      return _lock.synchronized(_box.deleteFromDisk);
    }
    return null;
  }
}
