import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:pedantic/pedantic.dart';

// ignore: implementation_imports
import 'package:hive/src/hive_impl.dart';

class MockBox extends Mock implements Box<dynamic> {}

void main() {
  group('HydratedStorage', () {
    final cwd = Directory.current.absolute.path;
    final storageDirectory = Directory(cwd);

    late Storage storage;

    tearDown(() async {
      await storage.clear();
    });

    group('migration', () {
      test('returns correct value when file exists', () async {
        File('${storageDirectory.path}/.hydrated_bloc.json')
          ..writeAsStringSync(json.encode({
            'CounterBloc': json.encode({'value': 4})
          }));
        storage = await HydratedStorage.build(
          storageDirectory: storageDirectory,
        );
        expect(storage.read('CounterBloc')['value'] as int, 4);
      });
    });

    group('build', () {
      setUp(() async {
        await (await HydratedStorage.build(storageDirectory: storageDirectory))
            .clear();
      });

      test('reuses existing instance when called multiple times', () async {
        final instanceA = storage = await HydratedStorage.build(
          storageDirectory: storageDirectory,
        );
        final instanceB = await HydratedStorage.build(
          storageDirectory: storageDirectory,
        );
        expect(instanceA, instanceB);
      });

      test('creates internal HiveImpl with correct directory', () async {
        storage = await HydratedStorage.build(
          storageDirectory: storageDirectory,
        );
        final box = HydratedStorage.hive.box<dynamic>('hydrated_box');
        expect(box, isNotNull);
        expect(box.path, p.join(storageDirectory.path, 'hydrated_box.hive'));
      });
    });

    group('default constructor', () {
      const key = '__key__';
      const value = '__value__';
      late Box box;

      setUp(() {
        box = MockBox();
        when(box).calls(#deleteFromDisk).thenReturn(Future<void>.value());
        storage = HydratedStorage(box);
      });

      group('read', () {
        test('returns null when box is not open', () {
          when(box).calls(#isOpen).thenReturn(false);
          expect(storage.read(key), isNull);
        });

        test('returns correct value when box is open', () {
          when(box).calls(#isOpen).thenReturn(true);
          when(box).calls(#get).thenReturn(value);
          expect(storage.read(key), value);
          verify(box).called(#get).withArgs(positional: [key]).once();
        });
      });

      group('write', () {
        test('does nothing when box is not open', () async {
          when(box).calls(#isOpen).thenReturn(false);
          await storage.write(key, value);
          verify(box).called(#put).never();
        });

        test('puts key/value in box when box is open', () async {
          when(box).calls(#isOpen).thenReturn(true);
          when(box).calls(#put).thenReturn(Future<void>.value());
          await storage.write(key, value);
          verify(box).called(#put).withArgs(positional: [key, value]).once();
        });
      });

      group('delete', () {
        test('does nothing when box is not open', () async {
          when(box).calls(#isOpen).thenReturn(false);
          await storage.delete(key);
          verify(box).called(#delete).never();
        });

        test('puts key/value in box when box is open', () async {
          when(box).calls(#isOpen).thenReturn(true);
          when(box).calls(#delete).thenReturn(Future<void>.value());
          await storage.delete(key);
          verify(box).called(#delete).withArgs(positional: [key]).once();
        });
      });

      group('clear', () {
        test('does nothing when box is not open', () async {
          when(box).calls(#isOpen).thenReturn(false);
          await storage.clear();
          verify(box).called(#deleteFromDisk).never();
        });

        test('deletes box when box is open', () async {
          when(box).calls(#isOpen).thenReturn(true);
          await storage.clear();
          verify(box).called(#deleteFromDisk).once();
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
        await storage.clear();
        await Hive.close();
        await Directory(temp).delete(recursive: true);
        await Directory(docs).delete(recursive: true);
      });

      test('Hive and Hydrated default directories', () async {
        Hive.init(docs);
        storage = await HydratedStorage.build(
          storageDirectory: Directory(temp)..createSync(),
        );

        var box = await Hive.openBox<String>('hive');
        await box.put('name', 'hive');
        expect(box.get('name'), 'hive');
        await Hive.close();

        // https://github.com/hivedb/hive/pull/521#issuecomment-767903897
        (Hive as HiveImpl).homePath = null;

        Hive.init(docs);
        box = await Hive.openBox<String>('hive');
        expect(box.get('name'), isNotNull);
        expect(box.get('name'), 'hive');
      });
    });
  });
}
