import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'cubits/cubits.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  group('blocTest', () {
    group('CounterCubit', () {
      blocTest<CounterCubit, int>(
        'emits [] when nothing is called',
        build: () async => CounterCubit(),
        expect: <int>[],
      );

      blocTest<CounterCubit, int>(
        'emits [1] when increment is called',
        build: () async => CounterCubit(),
        act: (cubit) async => cubit.increment(),
        expect: <int>[1],
      );

      blocTest<CounterCubit, int>(
        'emits [1] when increment is called with async act',
        build: () async => CounterCubit(),
        act: (cubit) async => cubit.increment(),
        expect: <int>[1],
      );

      blocTest<CounterCubit, int>(
        'emits [1, 2] when increment is called multiple times'
        'with async act',
        build: () async => CounterCubit(),
        act: (cubit) async => cubit..increment()..increment(),
        expect: <int>[1, 2],
      );
    });

    group('AsyncCounterCubit', () {
      blocTest<AsyncCounterCubit, int>(
        'emits [] when nothing is called',
        build: () async => AsyncCounterCubit(),
        expect: <int>[],
      );

      blocTest<AsyncCounterCubit, int>(
        'emits [1] when increment is called',
        build: () async => AsyncCounterCubit(),
        act: (cubit) async => cubit.increment(),
        expect: <int>[1],
      );

      blocTest<AsyncCounterCubit, int>(
        'emits [1, 2] when increment is called multiple'
        'times with async act',
        build: () async => AsyncCounterCubit(),
        act: (cubit) async {
          await cubit.increment();
          await cubit.increment();
        },
        expect: <int>[1, 2],
      );
    });

    group('DelayedCounterCubit', () {
      blocTest<DelayedCounterCubit, int>(
        'emits [] when nothing is called',
        build: () async => DelayedCounterCubit(),
        expect: <int>[],
      );

      blocTest<DelayedCounterCubit, int>(
        'emits [] when increment is called without wait',
        build: () async => DelayedCounterCubit(),
        act: (cubit) async => cubit.increment(),
        expect: <int>[],
      );

      blocTest<DelayedCounterCubit, int>(
        'emits [1] when increment is called with wait',
        build: () async => DelayedCounterCubit(),
        act: (cubit) async => cubit.increment(),
        wait: const Duration(milliseconds: 300),
        expect: <int>[1],
      );
    });

    group('MultiCounterCubit', () {
      blocTest<MultiCounterCubit, int>(
        'emits [] when nothing is called',
        build: () async => MultiCounterCubit(),
        expect: <int>[],
      );

      blocTest<MultiCounterCubit, int>(
        'emits [1, 2] when increment is called',
        build: () async => MultiCounterCubit(),
        act: (cubit) async => cubit.increment(),
        expect: <int>[1, 2],
      );

      blocTest<MultiCounterCubit, int>(
        'emits [1, 2, 3, 4] when increment is called'
        'multiple times with async act',
        build: () async => MultiCounterCubit(),
        act: (cubit) async => cubit..increment()..increment(),
        expect: <int>[1, 2, 3, 4],
      );
    });

    group('ComplexCubit', () {
      blocTest<ComplexCubit, ComplexState>(
        'emits [] when nothing is called',
        build: () async => ComplexCubit(),
        expect: <Matcher>[],
      );

      blocTest<ComplexCubit, ComplexState>(
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

      blocTest<SideEffectCounterCubit, int>(
        'emits [] when nothing is called',
        build: () async => SideEffectCounterCubit(repository),
        expect: <int>[],
      );

      blocTest<SideEffectCounterCubit, int>(
        'emits [1] when SideEffectCounterEvent.increment is called',
        build: () async => SideEffectCounterCubit(repository),
        act: (cubit) async => cubit.increment(),
        expect: <int>[1],
        verify: (_) async {
          verify(repository.sideEffect()).called(1);
        },
      );

      blocTest<SideEffectCounterCubit, int>(
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
