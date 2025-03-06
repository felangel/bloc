import 'dart:convert';
import 'dart:io';

import 'package:hive_ce/hive.dart';

/// The storage migration implementation when using dart:io.
Future<dynamic> migrate(String directory, Box<dynamic> box) async {
  final file = File('$directory/.hydrated_bloc.json');
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
