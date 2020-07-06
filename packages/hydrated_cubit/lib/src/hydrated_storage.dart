import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
// ignore: implementation_imports
import 'package:hive/src/hive_impl.dart';

import 'hydrated_cipher.dart';

/// Interface which is used to persist and retrieve state changes.
abstract class Storage {
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
/// Implementation of [Storage] which uses `PathProvider` and `dart.io`
/// to persist and retrieve state changes from the local device.
/// {@endtemplate}
class HydratedStorage implements Storage {
  /// {@macro hydrated_cubit_storage}
  @visibleForTesting
  HydratedStorage(this._box);

  /// Returns an instance of [HydratedStorage].
  /// [storageDirectory] can optionally be provided.
  /// By default, [getTemporaryDirectory] is used.
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
  static Future<HydratedStorage> build({
    Directory storageDirectory,
    HydratedCipher encryptionCipher,
  }) {
    return _lock.synchronized(() async {
      if (_instance != null) return _instance;
      final directory = storageDirectory ?? await getTemporaryDirectory();
      // Use HiveImpl directly to avoid conflicts with existing Hive.init
      // https://github.com/hivedb/hive/issues/336
      hive = HiveImpl();
      if (!kIsWeb) hive.init(directory.path);
      final box = await hive.openBox<dynamic>(
        'hydrated_box',
        encryptionCipher: encryptionCipher,
      );

      await _migrate(directory, box);

      return _instance = HydratedStorage(box);
    });
  }

  static Future _migrate(Directory directory, Box box) async {
    final file = File('${directory.path}/.hydrated_bloc.json');
    if (await file.exists()) {
      try {
        final dynamic storageJson = json.decode(await file.readAsString());
        final cache = (storageJson as Map).cast<String, String>();
        for (final key in cache.keys) {
          try {
            final string = cache[key];
            final dynamic object = json.decode(string);
            await box.put(key, object);
          } on dynamic catch (_) {}
        }
      } on dynamic catch (_) {} finally {
        await file.delete();
      }
    }
  }

  /// Internal instance of [HiveImpl].
  /// It should only be used for testing.
  @visibleForTesting
  static HiveInterface hive;

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
