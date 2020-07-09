import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_cubit/hydrated_cubit.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pedantic/pedantic.dart';

class MockBox extends Mock implements Box<dynamic> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  disablePathProviderPlatformOverride = true;

  group('HydratedStorage', () {
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

    group('migration', () {
      test('returns correct value when file exists', () async {
        final directory = await getTemporaryDirectory();
        File('${directory.path}/.hydrated_bloc.json')
          ..writeAsStringSync(json.encode({
            'CounterBloc': json.encode({'value': 4})
          }));
        storage = await HydratedStorage.build();
        expect(storage.read('CounterBloc')['value'] as int, 4);
      });
    });

    group('build', () {
      setUp(() async {
        await (await HydratedStorage.build()).clear();
        getTemporaryDirectoryCallCount = 0;
      });

      test('calls getTemporaryDirectory when storageDirectory is null',
          () async {
        storage = await HydratedStorage.build();
        expect(getTemporaryDirectoryCallCount, 1);
      });

      test(
          'does not call getTemporaryDirectory '
          'when storageDirectory is defined', () async {
        storage = await HydratedStorage.build(storageDirectory: Directory(cwd));
        expect(getTemporaryDirectoryCallCount, 0);
      });

      test('reuses existing instance when called multiple times', () async {
        final instanceA = storage = await HydratedStorage.build();
        final beforeCount = getTemporaryDirectoryCallCount;
        final instanceB = await HydratedStorage.build();
        final afterCount = getTemporaryDirectoryCallCount;
        expect(beforeCount, afterCount);
        expect(instanceA, instanceB);
      });

      test('creates internal HiveImpl with correct directory', () async {
        storage = await HydratedStorage.build();
        final box = HydratedStorage.hive?.box<dynamic>('hydrated_box');
        final directory = await getTemporaryDirectory();
        expect(box, isNotNull);
        expect(box.path, p.join(directory.path, 'hydrated_box.hive'));
      });
    });

    group('default constructor', () {
      const key = '__key__';
      const value = '__value__';
      Box box;

      setUp(() {
        box = MockBox();
        storage = HydratedStorage(box);
      });

      group('read', () {
        test('returns null when box is not open', () {
          when(box.isOpen).thenReturn(false);
          expect(storage.read(key), isNull);
        });

        test('returns correct value when box is open', () {
          when(box.isOpen).thenReturn(true);
          when<dynamic>(box.get(any)).thenReturn(value);
          expect(storage.read(key), value);
          verify<dynamic>(box.get(key)).called(1);
        });
      });

      group('write', () {
        test('does nothing when box is not open', () async {
          when(box.isOpen).thenReturn(false);
          await storage.write(key, value);
          verifyNever(box.put(any, any));
        });

        test('puts key/value in box when box is open', () async {
          when(box.isOpen).thenReturn(true);
          await storage.write(key, value);
          verify(box.put(key, value)).called(1);
        });
      });

      group('delete', () {
        test('does nothing when box is not open', () async {
          when(box.isOpen).thenReturn(false);
          await storage.delete(key);
          verifyNever(box.delete(any));
        });

        test('puts key/value in box when box is open', () async {
          when(box.isOpen).thenReturn(true);
          await storage.delete(key);
          verify(box.delete(key)).called(1);
        });
      });

      group('clear', () {
        test('does nothing when box is not open', () async {
          when(box.isOpen).thenReturn(false);
          await storage.clear();
          verifyNever(box.deleteFromDisk());
        });

        test('deletes box when box is open', () async {
          when(box.isOpen).thenReturn(true);
          await storage.clear();
          verify(box.deleteFromDisk()).called(1);
        });
      });
    });

    group('During heavy load', () {
      test('writes key/value pairs correctly', () async {
        const token = 'token';
        storage = await HydratedStorage.build(
          storageDirectory: Directory(cwd),
        );
        await Stream.fromIterable(
          Iterable.generate(120, (i) => i),
        ).asyncMap((i) async {
          final record = Iterable.generate(
            i,
            (i) => Iterable.generate(i, (j) => 'Point($i,$j);').toList(),
          ).toList();

          unawaited(storage.write(token, record));

          storage = await HydratedStorage.build(
            storageDirectory: Directory(cwd),
          );

          final written = storage.read(token) as List<List<String>>;
          expect(written, isNotNull);
          expect(written, record);
        }).drain<dynamic>();
      });
    });

    group('Storage interference', () {
      final temp = p.join(cwd, 'temp');
      final docs = p.join(cwd, 'docs');

      tearDown(() async {
        await Directory(temp).delete(recursive: true);
        await Directory(docs).delete(recursive: true);
      });

      test('Hive and Hydrated default directories', () async {
        Hive.init(docs);
        storage = await HydratedStorage.build(
          storageDirectory: Directory(temp),
        );

        var box = await Hive.openBox<String>('hive');
        await box.put('name', 'hive');
        expect(box.get('name'), 'hive');
        await Hive.close();

        Hive.init(docs);
        box = await Hive.openBox<String>('hive');
        try {
          expect(box.get('name'), isNotNull);
          expect(box.get('name'), 'hive');
        } finally {
          await storage.clear();
          await Hive.close();
        }
      });
    });
  });
}
