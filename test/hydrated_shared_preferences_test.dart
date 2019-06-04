import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HydratedSharedPreferences', () {
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/shared_preferences',
    );
    final List<MethodCall> log = <MethodCall>[];
    const Map<String, dynamic> testValues = <String, dynamic>{
      'flutter.String': 'hello world',
    };
    HydratedSharedPreferences hydratedPreferences;
    SharedPreferences preferences;

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'getAll') {
          return testValues;
        }
        return null;
      });
      preferences = await SharedPreferences.getInstance();
      hydratedPreferences = await HydratedSharedPreferences.getInstance();
      log.clear();
    });

    tearDown(() {
      preferences.clear();
    });

    group('read', () {
      test('reads from SharedPreferences cache', () async {
        expect(
          hydratedPreferences.read('String'),
          testValues['flutter.String'],
        );
        expect(log, <Matcher>[]);
      });
    });

    group('write', () {
      test('calls sharedPreferences setString', () async {
        await Future.wait(<Future<void>>[
          hydratedPreferences.write(
              'String', testValues['flutter.String'] as String),
        ]);
        expect(
          log,
          <Matcher>[
            isMethodCall('setString', arguments: <String, dynamic>{
              'key': 'flutter.String',
              'value': testValues['flutter.String']
            }),
          ],
        );
        log.clear();

        expect(
            hydratedPreferences.read('String'), testValues['flutter.String']);
        expect(log, equals(<MethodCall>[]));
      });
    });

    group('clear', () {
      test('calls SharedPreferences.remove follwoed by clear', () async {
        const String key = 'testKey';
        preferences..setString(key, null);
        (await HydratedSharedPreferences.getInstance()).clear();
        expect(
          log,
          <Matcher>[
            isMethodCall('remove', arguments: <String, dynamic>{
              'key': 'flutter.testKey',
            }),
            isMethodCall('clear', arguments: null)
          ],
        );
      });
    });
  });
}
