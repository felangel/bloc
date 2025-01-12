import 'dart:async';

import 'package:hive_ce/hive.dart';
// ignore: implementation_imports
import 'package:hive_ce/src/hive_impl.dart';
import 'package:hydrated_bloc/src/_migration/_migration_stub.dart'
    if (dart.library.io) 'package:hydrated_bloc/src/_migration/_migration_io.dart';
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

/// {@template hydrated_storage_directory}
/// A platform-agnostic storage directory representation.
/// {@endtemplate}
class HydratedStorageDirectory {
  /// {@macro hydrated_storage_directory}
  const HydratedStorageDirectory(this.path);

  /// The path to the storage directory.
  final String path;

  /// Sentinel directory used to determine that web storage should be used
  /// when initializing [HydratedStorage].
  ///
  /// ```dart
  /// await HydratedStorage.build(
  ///   storageDirectory: HydratedStorageDirectory.web,
  /// );
  /// ```
  static const web = HydratedStorageDirectory('');
}

/// {@template hydrated_storage}
/// Implementation of [Storage] which uses [package:hive_ce](https://pub.dev/packages/hive_ce)
/// to persist and retrieve state changes from the local device.
/// {@endtemplate}
class HydratedStorage implements Storage {
  /// {@macro hydrated_storage}
  @visibleForTesting
  HydratedStorage(this._box);

  /// Returns an instance of [HydratedStorage].
  /// [storageDirectory] is required.
  ///
  /// For web, use [HydratedStorageDirectory.web] as the `storageDirectory`
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
  ///         ? HydratedStorageDirectory.web
  ///         : HydratedStorageDirectory((await getTemporaryDirectory()).path),
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
    required HydratedStorageDirectory storageDirectory,
    HydratedCipher? encryptionCipher,
  }) {
    return _lock.synchronized(() async {
      // Use HiveImpl directly to avoid conflicts with existing Hive.init
      // https://github.com/hivedb/hive/issues/336
      hive = HiveImpl();
      Box<dynamic> box;

      if (storageDirectory == HydratedStorageDirectory.web) {
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
        await migrate(storageDirectory.path, box);
      }

      return HydratedStorage(box);
    });
  }

  /// Internal instance of [HiveImpl].
  /// It should only be used for testing.
  @visibleForTesting
  static late HiveInterface hive;

  static final _lock = Lock();

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
      return _lock.synchronized(_box.clear);
    }
  }

  @override
  Future<void> close() async {
    if (_box.isOpen) {
      return _lock.synchronized(_box.close);
    }
  }
}
