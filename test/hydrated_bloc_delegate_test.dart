import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('HydratedDelegate', () {
    HydratedBlocDelegate delegate;
    var getTemporaryDirectoryCallCount = 0;
    final response = '.';
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    channel.setMockMethodCallHandler((methodCall) async {
      if (methodCall.method == 'getTemporaryDirectory') {
        getTemporaryDirectoryCallCount++;
        return response;
      }
      throw UnimplementedError();
    });

    setUpAll(() async {
      await (await HydratedBlocStorage.getInstance()).clear();
    });

    setUp(() {
      getTemporaryDirectoryCallCount = 0;
    });

    tearDownAll(() async {
      await delegate?.storage?.clear();
    });

    group('Default Storage Directory', () {
      test('creates functional storage instance using getTemporaryDirectory',
          () async {
        delegate = await HydratedBlocDelegate.build();
        expect(getTemporaryDirectoryCallCount, 1);
        await delegate.storage.write('MockBloc', '{"nextState":"json"}');
        expect(delegate.storage.read('MockBloc'), '{"nextState":"json"}');
      });
    });

    group('Custom Storage Directory', () {
      test('creates functional storage instance using custom directory',
          () async {
        delegate = await HydratedBlocDelegate.build(
          storageDirectory: Directory.current,
        );
        await delegate.storage.write('MockBloc', '{"nextState":"json"}');
        expect(delegate.storage.read('MockBloc'), '{"nextState":"json"}');
      });
    });
  });
}
