import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

import '../hydrated_bloc.dart';

/// Interface which `HydratedBlocDelegate` uses to persist and retrieve
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

/// Implementation of [HydratedStorage] which uses `PathProvider` and `dart.io`
/// to persist and retrieve state changes from the local device.
class HydratedBlocStorage extends HydratedStorage {
  /// Returns an instance of `HydratedBlocStorage`.
  /// [storageDirectory] can optionally be provided.
  /// By default, `getTemporaryDirectory` is used.
  ///
  /// With [encryptionCipher] you can provide custom encryption.
  /// Following snippet shows how to make default one:
  /// ```dart
  /// import 'package:crypto/crypto.dart';
  /// import 'package:hydrated_bloc/hydrated_bloc.dart';
  ///
  /// const password = 'hydration';
  /// final byteskey = sha256.convert(utf8.encode(password)).bytes;
  /// return HydratedAesCipher(byteskey);
  /// ```
  static Future<HydratedBlocStorage> getInstance({
    Directory storageDirectory,
    HydratedCipher encryptionCipher,
  }) {
    return _lock.synchronized(() async {
      if (_instance != null) {
        return _instance;
      }

      final directory = storageDirectory ?? await getTemporaryDirectory();
      if (!kIsWeb) {
        Hive.init(directory.path);
      }

      final box = await Hive.openBox(
        'hydrated_box',
        encryptionCipher: encryptionCipher,
      );

      await _migrate(directory, box);

      return _instance = HydratedBlocStorage._(box);
    });
  }

  static Future _migrate(Directory directory, Box box) async {
    final file = File('${directory.path}/.hydrated_bloc.json');
    if (await file.exists()) {
      try {
        final storageJson = json.decode(await file.readAsString());
        final cache = (storageJson as Map).cast<String, String>();
        for (final key in cache.keys) {
          try {
            final string = cache[key];
            final object = json.decode(string);
            await box.put(key, object);
          } on dynamic catch (_) {}
        }
      } on dynamic catch (_) {} finally {
        await file.delete();
      }
    }
  }

  static final _lock = Lock();
  static HydratedStorage _instance;

  HydratedBlocStorage._(this._box);
  final Box _box;

  @override
  dynamic read(String key) {
    if (_box.isOpen) {
      return _box.get(key);
    } else {
      return null;
    }
  }

  @override
  Future<void> write(String key, dynamic value) {
    if (_box.isOpen) {
      return _lock.synchronized(() => _box.put(key, value));
    } else {
      return null;
    }
  }

  @override
  Future<void> delete(String key) {
    if (_box.isOpen) {
      return _lock.synchronized(() => _box.delete(key));
    } else {
      return null;
    }
  }

  @override
  Future<void> clear() {
    if (_box.isOpen) {
      _instance = null;
      return _lock.synchronized(_box.deleteFromDisk);
    } else {
      return null;
    }
  }
}
