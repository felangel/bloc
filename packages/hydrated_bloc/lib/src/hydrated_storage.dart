import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
// ignore: implementation_imports
import 'package:hive/src/hive_impl.dart';
import 'package:hydrated_bloc/src/hydrated_cipher.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

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

  /// Close the storage instance which will free any allocated resources.
  /// A storage instance can no longer be used once it is closed.
  Future<void> close();
}

/// {@template hydrated_storage}
/// Implementation of [Storage] which uses [package:hive](https://pub.dev/packages/hive)
/// to persist and retrieve state changes from the local device.
/// {@endtemplate}
class HydratedStorage implements Storage {
  /// {@macro hydrated_storage}
  @visibleForTesting
  HydratedStorage(this._box);

  /// Sentinel directory used to determine that web storage should be used
  /// when initializing [HydratedStorage].
  ///
  /// ```dart
  /// await HydratedStorage.build(
  ///   storageDirectory: HydratedStorage.webStorageDirectory,
  /// );
  /// ```
  static final webStorageDirectory = Directory('');

  /// Returns an instance of [HydratedStorage].
  /// [storageDirectory] is required.
  ///
  /// For web, use [webStorageDirectory] as the `storageDirectory`
  ///
  /// ```dart
  /// import 'package:flutter/foundation.dart';
  /// import 'package:flutter/material.dart';
  ///
  /// import 'package:hydrated_bloc/hydrated_bloc.dart';
  /// import 'package:path_provider/path_provider.dart';
  ///
  /// Future<void> main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   HydratedBloc.storage = await HydratedStorage.build(
  ///     storageDirectory: kIsWeb
  ///         ? HydratedStorage.webStorageDirectory
  ///         : await getTemporaryDirectory(),
  ///   );
  ///   runApp(App());
  /// }
  /// ```
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
  static Future<HydratedStorage> build({
    required Directory storageDirectory,
    HydratedCipher? encryptionCipher,
  }) {
    return _lock.synchronized(() async {
      if (_instance != null) return _instance!;
      // Use HiveImpl directly to avoid conflicts with existing Hive.init
      // https://github.com/hivedb/hive/issues/336
      hive = HiveImpl();
      Box<dynamic> box;

      if (storageDirectory == webStorageDirectory) {
        box = await hive.openBox<dynamic>(
          'hydrated_box',
          encryptionCipher: encryptionCipher,
        );
      } else {
        hive.init(storageDirectory.path);
        box = await hive.openBox<dynamic>(
          'hydrated_box',
          encryptionCipher: encryptionCipher,
        );
        await _migrate(storageDirectory, box);
      }

      return _instance = HydratedStorage(box);
    });
  }

  static Future<dynamic> _migrate(Directory directory, Box<dynamic> box) async {
    final file = File('${directory.path}/.hydrated_bloc.json');
    if (file.existsSync()) {
      try {
        final dynamic storageJson = json.decode(await file.readAsString());
        final cache = (storageJson as Map).cast<String, String>();
        for (final key in cache.keys) {
          try {
            final string = cache[key];
            final dynamic object = json.decode(string ?? '');
            await box.put(key, object);
          } catch (_) {}
        }
      } catch (_) {}
      await file.delete();
    }
  }

  /// Internal instance of [HiveImpl].
  /// It should only be used for testing.
  @visibleForTesting
  static late HiveInterface hive;

  static final _lock = Lock();
  static HydratedStorage? _instance;

  final Box<dynamic> _box;

  @override
  dynamic read(String key) => _box.isOpen ? _box.get(key) : null;

  @override
  Future<void> write(String key, dynamic value) async {
    if (_box.isOpen) {
      return _lock.synchronized(() => _box.put(key, value));
    }
  }

  @override
  Future<void> delete(String key) async {
    if (_box.isOpen) {
      return _lock.synchronized(() => _box.delete(key));
    }
  }

  @override
  Future<void> clear() async {
    if (_box.isOpen) {
      _instance = null;
      return _lock.synchronized(_box.clear);
    }
  }

  @override
  Future<void> close() async {
    if (_box.isOpen) {
      _instance = null;
      return _lock.synchronized(_box.close);
    }
  }
}
