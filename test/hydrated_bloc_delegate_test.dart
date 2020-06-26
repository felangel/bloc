import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('HydratedDelegate', () {
    HydratedBlocDelegate delegate;
    final response = Directory.current.absolute.path;
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    channel.setMockMethodCallHandler((methodCall) async {
      if (methodCall.method == 'getTemporaryDirectory') {
        return response;
      }
      throw UnimplementedError();
    });

    tearDown(() async {
      await delegate?.storage?.clear();
    });

    group('Default Storage Directory', () {
      test('creates functional storage instance using getTemporaryDirectory',
          () async {
        delegate = await HydratedBlocDelegate.build();
        await delegate.storage.write('MockBloc', {"nextState": "json"});
        expect(delegate.storage.read('MockBloc'), {'nextState': 'json'});
      });
    });

    group('Custom Storage Directory', () {
      test('creates functional storage instance using custom directory',
          () async {
        delegate = await HydratedBlocDelegate.build(
          storageDirectory: Directory.current,
        );
        await delegate.storage.write('MockBloc', {'nextState': 'json'});
        expect(delegate.storage.read('MockBloc'), {"nextState": "json"});
      });
    });
  });
}
