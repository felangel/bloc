import 'dart:async';

import 'package:cubit_test/cubit_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'helpers/helpers.dart';

class MockRepository extends Mock implements Repository {}

Future<void> delay() => Future.delayed(const Duration(microseconds: 1));

void main() {
  group('cubitTest', () {
    group('CounterCubit', () {
      cubitTest<CounterCubit, int>(
        'emits [] when nothing is called',
        build: () async => CounterCubit(),
        expect: <int>[],
      );

      cubitTest<CounterCubit, int>(
        'emits [0] when nothing is called and skip: 0',
        build: () async => CounterCubit(),
        skip: 0,
        expect: <int>[0],
      );

      cubitTest<CounterCubit, int>(
        'emits [1] when increment is called',
        build: () async => CounterCubit(),
        act: (cubit) async => cubit.increment(),
        expect: <int>[1],
      );

      cubitTest<CounterCubit, int>(
        'emits [1] when increment is called with async act',
        build: () async => CounterCubit(),
        act: (cubit) async {
          await delay();
          cubit.increment();
        },
        expect: <int>[1],
      );

      cubitTest<CounterCubit, int>(
        'emits [1, 2] when increment is called multiple times'
        'with async act',
        build: () async => CounterCubit(),
        act: (cubit) async {
          cubit.increment();
          await delay();
          cubit.increment();
        },
        expect: <int>[1, 2],
      );
    });

    group('AsyncCounterCubit', () {
      cubitTest<AsyncCounterCubit, int>(
        'emits [] when nothing is called',
        build: () async => AsyncCounterCubit(),
        expect: <int>[],
      );

      cubitTest<AsyncCounterCubit, int>(
        'emits [0] when nothing is called and skip: 0',
        build: () async => AsyncCounterCubit(),
        skip: 0,
        expect: <int>[0],
      );

      cubitTest<AsyncCounterCubit, int>(
        'emits [1] when increment is called',
        build: () async => AsyncCounterCubit(),
        act: (cubit) async => cubit.increment(),
        expect: <int>[1],
      );

      cubitTest<AsyncCounterCubit, int>(
        'emits [1, 2] when increment is called multiple'
        'times with async act',
        build: () async => AsyncCounterCubit(),
        act: (cubit) async {
          await cubit.increment();
          await delay();
          await cubit.increment();
        },
        expect: <int>[1, 2],
      );
    });

    group('DelayedCounterCubit', () {
      cubitTest<DelayedCounterCubit, int>(
        'emits [] when nothing is called',
        build: () async => DelayedCounterCubit(),
        expect: <int>[],
      );

      cubitTest<DelayedCounterCubit, int>(
        'emits [0] when nothing is called and skip: 0',
        build: () async => DelayedCounterCubit(),
        skip: 0,
        expect: <int>[0],
      );

      cubitTest<DelayedCounterCubit, int>(
        'emits [] when increment is called without wait',
        build: () async => DelayedCounterCubit(),
        act: (cubit) async => cubit.increment(),
        expect: <int>[],
      );

      cubitTest<DelayedCounterCubit, int>(
        'emits [1] when increment is called with wait',
        build: () async => DelayedCounterCubit(),
        act: (cubit) async => cubit.increment(),
        wait: const Duration(milliseconds: 300),
        expect: <int>[1],
      );
    });

    group('MultiCounterCubit', () {
      cubitTest<MultiCounterCubit, int>(
        'emits [] when nothing is called',
        build: () async => MultiCounterCubit(),
        expect: <int>[],
      );

      cubitTest<MultiCounterCubit, int>(
        'emits [0] when nothing is called and skip: 0',
        build: () async => MultiCounterCubit(),
        skip: 0,
        expect: <int>[0],
      );

      cubitTest<MultiCounterCubit, int>(
        'emits [1, 2] when increment is called',
        build: () async => MultiCounterCubit(),
        act: (cubit) async => cubit.increment(),
        expect: <int>[1, 2],
      );

      cubitTest<MultiCounterCubit, int>(
        'emits [1, 2, 3, 4] when increment is called'
        'multiple times with async act',
        build: () async => MultiCounterCubit(),
        act: (cubit) async {
          cubit.increment();
          await Future<void>.delayed(const Duration(milliseconds: 10));
          cubit.increment();
        },
        expect: <int>[1, 2, 3, 4],
      );
    });

    group('ComplexCubit', () {
      cubitTest<ComplexCubit, ComplexState>(
        'emits [] when nothing is called',
        build: () async => ComplexCubit(),
        expect: <Matcher>[],
      );

      cubitTest<ComplexCubit, ComplexState>(
        'emits [ComplexStateA] when nothing is called and skip: 0',
        build: () async => ComplexCubit(),
        skip: 0,
        expect: <Matcher>[isA<ComplexStateA>()],
      );

      cubitTest<ComplexCubit, ComplexState>(
        'emits [ComplexStateB] when emitB is called',
        build: () async => ComplexCubit(),
        act: (cubit) async => cubit.emitB(),
        expect: <Matcher>[isA<ComplexStateB>()],
      );
    });

    group('SideEffectCounterCubit', () {
      Repository repository;

      setUp(() {
        repository = MockRepository();
      });

      cubitTest<SideEffectCounterCubit, int>(
        'emits [] when nothing is called',
        build: () async => SideEffectCounterCubit(repository),
        expect: <int>[],
      );

      cubitTest<SideEffectCounterCubit, int>(
        'emits [0] when nothing is called and skip: 0',
        build: () async => SideEffectCounterCubit(repository),
        skip: 0,
        expect: <int>[0],
      );

      cubitTest<SideEffectCounterCubit, int>(
        'emits [1] when SideEffectCounterEvent.increment is called',
        build: () async => SideEffectCounterCubit(repository),
        act: (cubit) async => cubit.increment(),
        expect: <int>[1],
        verify: (_) async {
          verify(repository.sideEffect()).called(1);
        },
      );

      cubitTest<SideEffectCounterCubit, int>(
        'does not require an expect',
        build: () async => SideEffectCounterCubit(repository),
        act: (cubit) async => cubit.increment(),
        verify: (_) async {
          verify(repository.sideEffect()).called(1);
        },
      );
    });
  });
}
