import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

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
      test('persists and restores state correctly', () async {
        const item = 'foo';
        final cubit = ListCubit();
        expect(cubit.state, isEmpty);
        cubit.addItem(item);
        await sleep();
        expect(ListCubit().state, const <String>[item]);
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
  });
}
