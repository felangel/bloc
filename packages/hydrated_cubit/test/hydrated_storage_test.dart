import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_cubit/hydrated_cubit.dart';
import 'package:mockito/mockito.dart';
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

    tearDownAll(() async {
      await Hive.deleteBoxFromDisk('hydrated_box');
    });

    group('getInstance', () {
      setUp(() async {
        await (await HydratedCubitStorage.getInstance()).clear();
        getTemporaryDirectoryCallCount = 0;
      });

      test('calls getTemporaryDirectory when storageDirectory is null',
          () async {
        await HydratedCubitStorage.getInstance();
        expect(getTemporaryDirectoryCallCount, 1);
      });

      test(
          'does not call getTemporaryDirectory '
          'when storageDirectory is defined', () async {
        await HydratedCubitStorage.getInstance(
          storageDirectory: Directory(cwd),
        );
        expect(getTemporaryDirectoryCallCount, 0);
      });

      test('reuses existing instance when called multiple times', () async {
        final instanceA = await HydratedCubitStorage.getInstance();
        final beforeCount = getTemporaryDirectoryCallCount;
        final instanceB = await HydratedCubitStorage.getInstance();
        final afterCount = getTemporaryDirectoryCallCount;
        expect(beforeCount, afterCount);
        expect(instanceA, instanceB);
      });

      test('calls Hive.init with correct directory', () async {
        await HydratedCubitStorage.getInstance();
        final box = Hive.box<dynamic>('hydrated_box');
        final directory = await getTemporaryDirectory();
        expect(box, isNotNull);
        expect(box.path, '${directory.path}/hydrated_box.hive');
      });
    });

    group('default constructor', () {
      const key = '__key__';
      const value = '__value__';
      Box box;
      HydratedCubitStorage hydratedCubitStorage;

      setUp(() {
        box = MockBox();
        hydratedCubitStorage = HydratedCubitStorage(box);
      });

      group('read', () {
        test('returns null when box is not open', () {
          when(box.isOpen).thenReturn(false);
          expect(hydratedCubitStorage.read(key), isNull);
        });

        test('returns correct value when box is open', () {
          when(box.isOpen).thenReturn(true);
          when<dynamic>(box.get(any)).thenReturn(value);
          expect(hydratedCubitStorage.read(key), value);
          verify<dynamic>(box.get(key)).called(1);
        });
      });

      group('write', () {
        test('does nothing when box is not open', () async {
          when(box.isOpen).thenReturn(false);
          await hydratedCubitStorage.write(key, value);
          verifyNever(box.put(any, any));
        });

        test('puts key/value in box when box is open', () async {
          when(box.isOpen).thenReturn(true);
          await hydratedCubitStorage.write(key, value);
          verify(box.put(key, value)).called(1);
        });
      });

      group('delete', () {
        test('does nothing when box is not open', () async {
          when(box.isOpen).thenReturn(false);
          await hydratedCubitStorage.delete(key);
          verifyNever(box.delete(any));
        });

        test('puts key/value in box when box is open', () async {
          when(box.isOpen).thenReturn(true);
          await hydratedCubitStorage.delete(key);
          verify(box.delete(key)).called(1);
        });
      });

      group('clear', () {
        test('does nothing when box is not open', () async {
          when(box.isOpen).thenReturn(false);
          await hydratedCubitStorage.clear();
          verifyNever(box.deleteFromDisk());
        });

        test('deletes box when box is open', () async {
          when(box.isOpen).thenReturn(true);
          await hydratedCubitStorage.clear();
          verify(box.deleteFromDisk()).called(1);
        });
      });
    });

    group('During heavy load', () {
      test('writes key/value pairs correctly', () async {
        const token = 'token';
        var hydratedStorage = await HydratedCubitStorage.getInstance(
          storageDirectory: Directory(cwd),
        );
        await Stream.fromIterable(
          Iterable.generate(120, (i) => i),
        ).asyncMap((i) async {
          final record = Iterable.generate(
            i,
            (i) => Iterable.generate(i, (j) => 'Point($i,$j);').toList(),
          ).toList();

          unawaited(hydratedStorage.write(token, record));

          hydratedStorage = await HydratedCubitStorage.getInstance(
            storageDirectory: Directory(cwd),
          );

          final written = hydratedStorage.read(token) as List<List<String>>;
          expect(written, isNotNull);
          expect(written, record);
        }).drain<dynamic>();
      });
    });
  });
}
