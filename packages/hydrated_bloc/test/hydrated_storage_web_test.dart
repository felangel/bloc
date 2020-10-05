@TestOn('browser')
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('HydratedStorage (Web)', () {
    final cwd = Directory.current.absolute.path;
    var getTemporaryDirectoryCallCount = 0;
    const MethodChannel('plugins.flutter.io/path_provider')
      ..setMockMethodCallHandler((methodCall) async {
        if (methodCall.method == 'getTemporaryDirectory') {
          getTemporaryDirectoryCallCount++;
          return cwd;
        }
        throw UnimplementedError();
      });

    Storage storage;

    tearDown(() async {
      await storage?.clear();
    });

    test(
        'does not call getTemporaryDirectory '
        'when storageDirectory is null', () {
      HydratedStorage.build().catchError((Object _) {
        expect(getTemporaryDirectoryCallCount, 0);
      });
    });
  });
}
