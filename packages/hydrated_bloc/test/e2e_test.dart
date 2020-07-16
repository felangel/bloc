import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:hydrated_bloc/src/hydrated_cubit.dart';

import 'cubits/cubits.dart';

Future<void> sleep() => Future<void>.delayed(const Duration(milliseconds: 100));

void main() {
  group('E2E', () {
    Storage storage;

    setUp(() async {
      storage = await HydratedStorage.build(
        storageDirectory: Directory.current,
      );
      HydratedBloc.storage = storage;
    });

    tearDown(() async {
      await storage?.clear();
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
        const item = ToMapObject(1);
        fromJson(dynamic x) => ToMapObject.fromJson(x as Map<String, dynamic>);
        final cubit = HeavyListCubit<ToMapObject>(fromJson);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          HeavyListCubit<ToMapObject>(fromJson).state,
          const <ToMapObject>[item],
        );
      });

      test('persists and restores object->list list correctly', () async {
        const item = ToListObject(1);
        fromJson(dynamic x) => ToListObject.fromJson(x as List<dynamic>);
        final cubit = HeavyListCubit<ToListObject>(fromJson);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          HeavyListCubit<ToListObject>(fromJson).state,
          const <ToListObject>[item],
        );
      });

      test('persists and restores object->list<map> list correctly', () async {
        final item = ToListMapObject(1);
        fromJson(dynamic x) => ToListMapObject.fromJson(x as List<dynamic>);
        final cubit = HeavyListCubit<ToListMapObject>(fromJson);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          HeavyListCubit<ToListMapObject>(fromJson).state,
          <ToListMapObject>[item],
        );
      });

      test('persists and restores object->list<list> list correctly', () async {
        final item = ToListListObject(1);
        fromJson(dynamic x) => ToListListObject.fromJson(x as List<dynamic>);
        final cubit = HeavyListCubit<ToListListObject>(fromJson);
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(
          HeavyListCubit<ToListListObject>(fromJson).state,
          <ToListListObject>[item],
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
          throwsA(isA<CubitUnhandledErrorException>().having(
            (dynamic e) => e.error,
            'inner error of cubit error',
            isA<HydratedUnsupportedError>().having(
              (dynamic e) => e.cause,
              'cycle2 -> cycle1 -> cycle2 ->',
              isA<HydratedCyclicError>(),
            ),
          )),
        );
      });
    });

    group('BadCubit', () {
      test('throws unsupported object: no `toJson`', () async {
        final cubit = BadCubit();
        expect(cubit.state, isNull);
        expect(
          cubit.setBad,
          throwsA(isA<CubitUnhandledErrorException>().having(
            (dynamic e) => e.error,
            'inner error of cubit error',
            isA<HydratedUnsupportedError>().having(
              (dynamic e) => e.cause,
              'Object has no `toJson`',
              isA<NoSuchMethodError>(),
            ),
          )),
        );
      });

      test('throws unsupported object: bad `toJson`', () async {
        final cubit = BadCubit();
        expect(cubit.state, isNull);
        expect(
          () => cubit.setBad(VeryBadObject()),
          throwsA(isA<CubitUnhandledErrorException>().having(
            (dynamic e) => e.error,
            'inner error of cubit error',
            isA<HydratedUnsupportedError>(),
          )),
        );
      });
    });
  });
}
