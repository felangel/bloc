import 'dart:io';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:hydrated_bloc/src/hydrated_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'cubits/cubits.dart';

Future<void> sleep() => Future<void>.delayed(const Duration(milliseconds: 100));

void main() {
  group('E2E', () {
    late Storage storage;

    setUp(() async {
      storage = await HydratedStorage.build(
        storageDirectory: Directory(
          path.join(Directory.current.path, '.cache'),
        ),
      );
      HydratedBloc.storage = storage;
    });

    tearDown(() async {
      await storage.clear();
      try {
        Directory(
          path.join(Directory.current.path, '.cache'),
        ).deleteSync(recursive: true);
        await HydratedStorage.hive.deleteFromDisk();
      } catch (_) {}
    });

    test('NIL constructor', () {
      // ignore: prefer_const_constructors
      NIL();
    });

    group('FreezedCubit', () {
      test('persists and restores state correctly', () async {
        const tree = Tree(
          question: Question(id: 0, question: '?00'),
          left: Tree(
            question: Question(id: 1, question: '?01'),
          ),
          right: Tree(
            question: Question(id: 2, question: '?02'),
            left: Tree(question: Question(id: 3, question: '?03')),
            right: Tree(question: Question(id: 4, question: '?04')),
          ),
        );
        final cubit = FreezedCubit();
        expect(cubit.state, isNull);
        cubit.setQuestion(tree);
        await sleep();
        expect(FreezedCubit().state, tree);
      });
    });

    group('JsonSerializableCubit', () {
      test('persists and restores state correctly', () async {
        final cubit = JsonSerializableCubit();
        final expected = const User.initial().copyWith(
          favoriteColor: Color.green,
        );
        expect(cubit.state, const User.initial());
        cubit.updateFavoriteColor(Color.green);
        await sleep();
        expect(JsonSerializableCubit().state, expected);
      });
    });

    group('ListCubit', () {
      test('persists and restores string list correctly', () async {
        const item = 'foo';
        final cubit = ListCubit();
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(ListCubit().state, const <String>[item]);
      });

      test('persists and restores object->map list correctly', () async {
        const item = MapObject(1);
        const fromJson = MapObject.fromJson;
        final cubit = ListCubitMap<MapObject, int>(fromJson);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          ListCubitMap<MapObject, int>(fromJson).state,
          const <MapObject>[item],
        );
      });

      test('persists and restores object-*>map list correctly', () async {
        const item = MapObject(1);
        const fromJson = MapObject.fromJson;
        final cubit = ListCubitMap<MapObject, int>(fromJson, true);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          ListCubitMap<MapObject, int>(fromJson).state,
          const <MapObject>[item],
        );
      });

      test('persists and restores obj->map<custom> list correctly', () async {
        final item = MapCustomObject(1);
        const fromJson = MapCustomObject.fromJson;
        final cubit = ListCubitMap<MapCustomObject, CustomObject>(fromJson);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          ListCubitMap<MapCustomObject, CustomObject>(fromJson).state,
          <MapCustomObject>[item],
        );
      });

      test('persists and restores obj-*>map<custom> list correctly', () async {
        final item = MapCustomObject(1);
        const fromJson = MapCustomObject.fromJson;
        final cubit =
            ListCubitMap<MapCustomObject, CustomObject>(fromJson, true);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          ListCubitMap<MapCustomObject, CustomObject>(fromJson).state,
          <MapCustomObject>[item],
        );
      });

      test('persists and restores object->list list correctly', () async {
        const item = ListObject(1);
        const fromJson = ListObject.fromJson;
        final cubit = ListCubitList<ListObject, int>(fromJson);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          ListCubitList<ListObject, int>(fromJson).state,
          const <ListObject>[item],
        );
      });

      test('persists and restores object-*>list list correctly', () async {
        const item = ListObject(1);
        const fromJson = ListObject.fromJson;
        final cubit = ListCubitList<ListObject, int>(fromJson, true);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          ListCubitList<ListObject, int>(fromJson).state,
          const <ListObject>[item],
        );
      });

      test('persists and restores object->list<map> list correctly', () async {
        final item = ListMapObject(1);
        const fromJson = ListMapObject.fromJson;
        final cubit = ListCubitList<ListMapObject, MapObject>(fromJson);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          ListCubitList<ListMapObject, MapObject>(fromJson).state,
          <ListMapObject>[item],
        );
      });

      test('persists and restores obj-*>list<map> list correctly', () async {
        final item = ListMapObject(1);
        const fromJson = ListMapObject.fromJson;
        final cubit = ListCubitList<ListMapObject, MapObject>(fromJson, true);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          ListCubitList<ListMapObject, MapObject>(fromJson).state,
          <ListMapObject>[item],
        );
      });

      test('persists and restores obj->list<list> list correctly', () async {
        final item = ListListObject(1);
        const fromJson = ListListObject.fromJson;
        final cubit = ListCubitList<ListListObject, ListObject>(fromJson);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          ListCubitList<ListListObject, ListObject>(fromJson).state,
          <ListListObject>[item],
        );
      });

      test('persists and restores obj-*>list<list> list correctly', () async {
        final item = ListListObject(1);
        const fromJson = ListListObject.fromJson;
        final cubit = ListCubitList<ListListObject, ListObject>(
          fromJson,
          true,
        );
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          ListCubitList<ListListObject, ListObject>(fromJson).state,
          <ListListObject>[item],
        );
      });

      test('persists and restores obj->list<custom> list correctly', () async {
        final item = ListCustomObject(1);
        const fromJson = ListCustomObject.fromJson;
        final cubit = ListCubitList<ListCustomObject, CustomObject>(fromJson);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          ListCubitList<ListCustomObject, CustomObject>(fromJson).state,
          <ListCustomObject>[item],
        );
      });

      test('persists and restores obj-*>list<custom> list correctly', () async {
        final item = ListCustomObject(1);
        const fromJson = ListCustomObject.fromJson;
        final cubit =
            ListCubitList<ListCustomObject, CustomObject>(fromJson, true);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          ListCubitList<ListCustomObject, CustomObject>(fromJson).state,
          <ListCustomObject>[item],
        );
      });

      test('persists and restores obj->list<custom> empty list correctly',
          () async {
        const fromJson = ListCustomObject.fromJson;
        final cubit = ListCubitList<ListCustomObject, CustomObject>(fromJson);
        expect(cubit.state, isEmpty);
        cubit.reset();
        await sleep();
        expect(
          ListCubitList<ListCustomObject, CustomObject>(fromJson).state,
          isEmpty,
        );
      });

      test('persists and restores obj-*>list<custom> empty list correctly',
          () async {
        const fromJson = ListCustomObject.fromJson;
        final cubit =
            ListCubitList<ListCustomObject, CustomObject>(fromJson, true);
        expect(cubit.state, isEmpty);
        cubit.reset();
        await sleep();
        expect(
          ListCubitList<ListCustomObject, CustomObject>(fromJson).state,
          isEmpty,
        );
      });
    });

    group('ManualCubit', () {
      test('persists and restores state correctly', () async {
        const dog = Dog('Rover', 5, [Toy('Ball')]);
        final cubit = ManualCubit();
        expect(cubit.state, isNull);
        cubit.setDog(dog);
        await sleep();
        expect(ManualCubit().state, dog);
      });
    });

    group('SimpleCubit', () {
      test('persists and restores state correctly', () async {
        final cubit = SimpleCubit();
        expect(cubit.state, 0);
        cubit.increment();
        expect(cubit.state, 1);
        await sleep();
        expect(SimpleCubit().state, 1);
      });

      test('does not throw after clear', () async {
        final cubit = SimpleCubit();
        expect(cubit.state, 0);
        cubit.increment();
        expect(cubit.state, 1);
        await storage.clear();
        expect(SimpleCubit().state, 0);
      });
    });

    group('CyclicCubit', () {
      test('throws cyclic error', () async {
        final cycle2 = Cycle2();
        final cycle1 = Cycle1(cycle2);
        cycle2.cycle1 = cycle1;
        final cubit = CyclicCubit();
        expect(cubit.state, isNull);
        expect(
          () => cubit.setCyclic(cycle1),
          throwsA(
            isA<HydratedUnsupportedError>().having(
              (dynamic e) => e.cause,
              'cycle2 -> cycle1 -> cycle2 ->',
              isA<HydratedCyclicError>(),
            ),
          ),
        );
      });
    });

    group('BadCubit', () {
      test('throws unsupported object: no `toJson`', () async {
        final cubit = BadCubit();
        expect(cubit.state, isNull);
        expect(
          cubit.setBad,
          throwsA(
            isA<HydratedUnsupportedError>().having(
              (dynamic e) => e.cause,
              'Object has no `toJson`',
              isA<NoSuchMethodError>(),
            ),
          ),
        );
      });

      test('throws unsupported object: bad `toJson`', () async {
        final cubit = BadCubit();
        expect(cubit.state, isNull);
        expect(
          () => cubit.setBad(VeryBadObject()),
          throwsA(isA<HydratedUnsupportedError>()),
        );
      });
    });
  });
}
