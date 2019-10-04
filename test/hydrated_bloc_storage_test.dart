import 'dart:io' hide Platform;
import 'dart:convert';
import 'package:platform/platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  group('HydratedBlocStorage', () {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    String response = '.';
    HydratedBlocStorage hydratedStorage;

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return response;
    });

    tearDown(() {
      hydratedStorage.clear();
    });

    group('read', () {
      test('returns null when file does not exist', () async {
        hydratedStorage = await HydratedBlocStorage.getInstance();
        expect(
          hydratedStorage.read('CounterBloc'),
          isNull,
        );
      });

      test('returns correct value when file exists on iOS', () async {
        final file = File('./.hydrated_bloc.json');
        file.writeAsStringSync(json.encode({
          "CounterBloc": {"value": 4}
        }));
        hydratedStorage = await HydratedBlocStorage.getInstance(
          FakePlatform(operatingSystem: 'ios'),
        );
        expect(hydratedStorage.read('CounterBloc')['value'] as int, 4);
      });

      test('returns correct value when file exists on Android', () async {
        final file = File('./.hydrated_bloc.json');
        file.writeAsStringSync(json.encode({
          "CounterBloc": {"value": 4}
        }));
        hydratedStorage = await HydratedBlocStorage.getInstance(
          FakePlatform(operatingSystem: 'android'),
        );
        expect(hydratedStorage.read('CounterBloc')['value'] as int, 4);
      });

      test('returns correct value when file exists on Fuchsia', () async {
        final file = File('./.hydrated_bloc.json');
        file.writeAsStringSync(json.encode({
          "CounterBloc": {"value": 4}
        }));
        hydratedStorage = await HydratedBlocStorage.getInstance(
          FakePlatform(operatingSystem: 'fuchsia'),
        );
        expect(hydratedStorage.read('CounterBloc')['value'] as int, 4);
      });

      test('returns correct value when file exists on Windows', () async {
        final file = File('.\\.config/.hydrated_bloc.json')
          ..createSync(recursive: true);
        file.writeAsStringSync(json.encode({
          "CounterBloc": {"value": 4}
        }));
        hydratedStorage = await HydratedBlocStorage.getInstance(
          FakePlatform(
            operatingSystem: 'windows',
            environment: {'UserProfile': '.'},
          ),
        );
        expect(hydratedStorage.read('CounterBloc')['value'] as int, 4);
        file.deleteSync();
      });

      test('returns correct value when file exists on MacOS', () async {
        final file = File('./.config/.hydrated_bloc.json')
          ..createSync(recursive: true);
        file.writeAsStringSync(json.encode({
          "CounterBloc": {"value": 4}
        }));
        hydratedStorage = await HydratedBlocStorage.getInstance(
          FakePlatform(
            operatingSystem: 'macos',
            environment: {'HOME': '.'},
          ),
        );
        expect(hydratedStorage.read('CounterBloc')['value'] as int, 4);
        file.deleteSync();
      });

      test('returns correct value when file exists on Linux', () async {
        final file = File('./.config/.hydrated_bloc.json')
          ..createSync(recursive: true);
        file.writeAsStringSync(json.encode({
          "CounterBloc": {"value": 4}
        }));
        hydratedStorage = await HydratedBlocStorage.getInstance(
          FakePlatform(
            operatingSystem: 'linux',
            environment: {'HOME': '.'},
          ),
        );
        expect(hydratedStorage.read('CounterBloc')['value'] as int, 4);
        file.deleteSync();
      });

      test(
          'returns null value when file exists but contains corrupt json and deletes the file',
          () async {
        final file = File('./.hydrated_bloc.json');
        file.writeAsStringSync("invalid-json");
        hydratedStorage = await HydratedBlocStorage.getInstance(
          FakePlatform(operatingSystem: 'ios'),
        );
        expect(hydratedStorage.read('CounterBloc'), isNull);
        expect(file.existsSync(), false);
      });
    });

    group('write', () {
      test('writes to file', () async {
        hydratedStorage = await HydratedBlocStorage.getInstance(
          FakePlatform(operatingSystem: 'ios'),
        );
        await Future.wait(<Future<void>>[
          hydratedStorage.write('CounterBloc', json.encode({"value": 4})),
        ]);

        expect(hydratedStorage.read('CounterBloc'), '{"value":4}');
      });
    });

    group('clear', () {
      test('calls deletes file, clears storage, and resets instance', () async {
        hydratedStorage = await HydratedBlocStorage.getInstance(
          FakePlatform(operatingSystem: 'ios'),
        );
        await Future.wait(<Future<void>>[
          hydratedStorage.write('CounterBloc', json.encode({"value": 4})),
        ]);

        expect(hydratedStorage.read('CounterBloc'), '{"value":4}');
        await hydratedStorage.clear();
        expect(hydratedStorage.read('CounterBloc'), isNull);
        final file = File('./.hydrated_bloc.json');
        expect(file.existsSync(), false);
      });
    });
  });
}
