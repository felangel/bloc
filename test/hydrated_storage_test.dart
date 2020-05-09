import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('HydratedStorage', () {
    group('Default Storage Directory', () {
      final response = '.';
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      channel.setMockMethodCallHandler((methodCall) async {
        if (methodCall.method == 'getTemporaryDirectory') {
          return response;
        }
        throw UnimplementedError();
      });
      HydratedBlocStorage hydratedStorage;

      setUpAll(() async {
        await (await HydratedBlocStorage.getInstance()).clear();
      });

      tearDown(() async {
        await hydratedStorage?.clear();
      });

      group('read', () {
        test('returns null when file does not exist', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance();
          expect(
            hydratedStorage.read('CounterBloc'),
            isNull,
          );
        });

        test('returns correct value when file exists', () async {
          final file = File('./.hydrated_bloc.json');
          file.writeAsStringSync(json.encode({
            "CounterBloc": {"value": 4}
          }));
          hydratedStorage = await HydratedBlocStorage.getInstance();
          expect(hydratedStorage.read('CounterBloc')['value'] as int, 4);
        });

        test(
            'returns null value'
            'when file exists but contains corrupt json and deletes the file',
            () async {
          final file = File('./.hydrated_bloc.json');
          file.writeAsStringSync("invalid-json");
          hydratedStorage = await HydratedBlocStorage.getInstance();
          expect(hydratedStorage.read('CounterBloc'), isNull);
          expect(file.existsSync(), false);
        });
      });

      group('write', () {
        test('writes to file', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance();
          await hydratedStorage.write('CounterBloc', json.encode({"value": 4}));

          expect(hydratedStorage.read('CounterBloc'), '{"value":4}');
        });
      });

      group('clear', () {
        test('calls deletes file, clears storage, and resets instance',
            () async {
          hydratedStorage = await HydratedBlocStorage.getInstance();
          await hydratedStorage.write('CounterBloc', json.encode({"value": 4}));

          expect(hydratedStorage.read('CounterBloc'), '{"value":4}');
          await hydratedStorage.clear();
          expect(hydratedStorage.read('CounterBloc'), isNull);
          final file = File('./.hydrated_bloc.json');
          expect(file.existsSync(), false);
        });
      });

      group('delete', () {
        test('does nothing for non-existing key value pair', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance();

          expect(hydratedStorage.read('CounterBloc'), null);
          await hydratedStorage.delete('CounterBloc');
          expect(hydratedStorage.read('CounterBloc'), isNull);
        });

        test('deletes existing key value pair', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance();
          await hydratedStorage.write('CounterBloc', json.encode({"value": 4}));

          expect(hydratedStorage.read('CounterBloc'), '{"value":4}');

          await hydratedStorage.delete('CounterBloc');
          expect(hydratedStorage.read('CounterBloc'), isNull);
        });
      });
    });

    group('Custom Storage Directory', () {
      HydratedBlocStorage hydratedStorage;

      tearDown(() async {
        await hydratedStorage.clear();
      });

      group('read', () {
        test('returns null when file does not exist', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );
          expect(
            hydratedStorage.read('CounterBloc'),
            isNull,
          );
        });

        test('returns correct value when file exists', () async {
          final file = File('./.hydrated_bloc.json');
          file.writeAsStringSync(json.encode({
            "CounterBloc": {"value": 4}
          }));
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );
          expect(hydratedStorage.read('CounterBloc')['value'] as int, 4);
        });

        test(
            'returns null value'
            'when file exists but contains corrupt json and deletes the file',
            () async {
          final file = File('./.hydrated_bloc.json');
          file.writeAsStringSync("invalid-json");
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );
          expect(hydratedStorage.read('CounterBloc'), isNull);
          expect(file.existsSync(), false);
        });
      });

      group('write', () {
        test('writes to file', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );
          await hydratedStorage.write('CounterBloc', json.encode({"value": 4}));

          expect(hydratedStorage.read('CounterBloc'), '{"value":4}');
        });
      });

      group('heavy write', () {
        test('writes heavily to file', () async {
          final token = 'CounterBloc';
          final directory = Directory.current;
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: directory,
          );
          final tasks = Iterable.generate(120, (i) => i).map((i) async {
            final record = Iterable.generate(
              i,
              (i) => Iterable.generate(i, (j) => 'Point($i,$j);').toList(),
            ).toList();
            hydratedStorage.write(token, record); // no await here

            hydratedStorage = await HydratedBlocStorage.getInstance(
              storageDirectory: directory,
            ); // basically refreshes cache

            final written = hydratedStorage.read(token);
            expect(written, record);
          });

          await Future.wait(tasks, eagerError: true);
        });
      });

      group('clear', () {
        test('calls deletes file, clears storage, and resets instance',
            () async {
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );
          await hydratedStorage.write('CounterBloc', json.encode({"value": 4}));

          expect(hydratedStorage.read('CounterBloc'), '{"value":4}');
          await hydratedStorage.clear();
          expect(hydratedStorage.read('CounterBloc'), isNull);
          final file = File('./.hydrated_bloc.json');
          expect(file.existsSync(), false);
        });
      });

      group('delete', () {
        test('does nothing for non-existing key value pair', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );

          expect(hydratedStorage.read('CounterBloc'), null);
          await hydratedStorage.delete('CounterBloc');
          expect(hydratedStorage.read('CounterBloc'), isNull);
        });

        test('deletes existing key value pair', () async {
          hydratedStorage = await HydratedBlocStorage.getInstance(
            storageDirectory: Directory.current,
          );
          await hydratedStorage.write('CounterBloc', json.encode({"value": 4}));

          expect(hydratedStorage.read('CounterBloc'), '{"value":4}');

          await hydratedStorage.delete('CounterBloc');
          expect(hydratedStorage.read('CounterBloc'), isNull);
        });
      });
    });
  });
}
