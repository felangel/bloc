import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'cubits/cubits.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  group('blocTest', () {
    group('CounterCubit', () {
      blocTest<CounterCubit, int>(
        'emits [] when nothing is called',
        build: () => CounterCubit(),
        expect: () => <int>[],
      );

      blocTest<CounterCubit, int>(
        'emits [1] when increment is called',
        build: () => CounterCubit(),
        act: (cubit) => cubit.increment(),
        expect: () => <int>[1],
      );

      blocTest<CounterCubit, int>(
        'emits [1] when increment is called with async act',
        build: () => CounterCubit(),
        act: (cubit) => cubit.increment(),
        expect: () => <int>[1],
      );

      blocTest<CounterCubit, int>(
        'emits [1, 2] when increment is called multiple times '
        'with async act',
        build: () => CounterCubit(),
        act: (cubit) => cubit
          ..increment()
          ..increment(),
        expect: () => <int>[1, 2],
      );

      blocTest<CounterCubit, int>(
        'emits [3] when increment is called and seed is 2 '
        'with async act',
        build: () => CounterCubit(),
        seed: () => 2,
        act: (cubit) => cubit.increment(),
        expect: () => <int>[3],
      );

      blocTest<CounterCubit, int>(
        'emits [1] when increment is called and expect is async',
        build: () => CounterCubit(),
        act: (cubit) => cubit.increment(),
        expect: () async => <int>[1],
      );
    });

    group('AsyncCounterCubit', () {
      blocTest<AsyncCounterCubit, int>(
        'emits [] when nothing is called',
        build: () => AsyncCounterCubit(),
        expect: () => <int>[],
      );

      blocTest<AsyncCounterCubit, int>(
        'emits [1] when increment is called',
        build: () => AsyncCounterCubit(),
        act: (cubit) => cubit.increment(),
        expect: () => <int>[1],
      );

      blocTest<AsyncCounterCubit, int>(
        'emits [1, 2] when increment is called multiple '
        'times with async act',
        build: () => AsyncCounterCubit(),
        act: (cubit) async {
          await cubit.increment();
          await cubit.increment();
        },
        expect: () => <int>[1, 2],
      );
    });

    group('DelayedCounterCubit', () {
      blocTest<DelayedCounterCubit, int>(
        'emits [] when nothing is called',
        build: () => DelayedCounterCubit(),
        expect: () => <int>[],
      );

      blocTest<DelayedCounterCubit, int>(
        'emits [] when increment is called without wait',
        build: () => DelayedCounterCubit(),
        act: (cubit) => cubit.increment(),
        expect: () => <int>[],
      );

      blocTest<DelayedCounterCubit, int>(
        'emits [1] when increment is called with wait',
        build: () => DelayedCounterCubit(),
        act: (cubit) => cubit.increment(),
        wait: const Duration(milliseconds: 300),
        expect: () => <int>[1],
      );
    });

    group('InstantEmitCubit', () {
      blocTest<InstantEmitCubit, int>(
        'emits [] when nothing is called',
        build: () => InstantEmitCubit(),
        expect: () => <int>[],
      );

      blocTest<InstantEmitCubit, int>(
        'emits [2] when increment is called',
        build: () => InstantEmitCubit(),
        act: (cubit) => cubit.increment(),
        expect: () => <int>[2],
      );

      blocTest<InstantEmitCubit, int>(
        'emits [2, 3] when increment is called '
        'multiple times with async act',
        build: () => InstantEmitCubit(),
        act: (cubit) => cubit
          ..increment()
          ..increment(),
        expect: () => <int>[2, 3],
      );
    });

    group('MultiCounterCubit', () {
      blocTest<MultiCounterCubit, int>(
        'emits [] when nothing is called',
        build: () => MultiCounterCubit(),
        expect: () => <int>[],
      );

      blocTest<MultiCounterCubit, int>(
        'emits [1, 2] when increment is called',
        build: () => MultiCounterCubit(),
        act: (cubit) => cubit.increment(),
        expect: () => <int>[1, 2],
      );

      blocTest<MultiCounterCubit, int>(
        'emits [1, 2, 3, 4] when increment is called '
        'multiple times with async act',
        build: () => MultiCounterCubit(),
        act: (cubit) => cubit
          ..increment()
          ..increment(),
        expect: () => <int>[1, 2, 3, 4],
      );
    });

    group('ComplexCubit', () {
      blocTest<ComplexCubit, ComplexState>(
        'emits [] when nothing is called',
        build: () => ComplexCubit(),
        expect: () => <Matcher>[],
      );

      blocTest<ComplexCubit, ComplexState>(
        'emits [ComplexStateB] when emitB is called',
        build: () => ComplexCubit(),
        act: (cubit) => cubit.emitB(),
        expect: () => [isA<ComplexStateB>()],
      );
    });

    group('SideEffectCounterCubit', () {
      late Repository repository;

      setUp(() {
        repository = MockRepository();
        when(() => repository.sideEffect()).thenReturn(null);
      });

      blocTest<SideEffectCounterCubit, int>(
        'emits [] when nothing is called',
        build: () => SideEffectCounterCubit(repository),
        expect: () => <int>[],
      );

      blocTest<SideEffectCounterCubit, int>(
        'emits [1] when increment is called',
        build: () => SideEffectCounterCubit(repository),
        act: (cubit) => cubit.increment(),
        expect: () => <int>[1],
        verify: (_) async {
          verify(() => repository.sideEffect()).called(1);
        },
      );

      blocTest<SideEffectCounterCubit, int>(
        'does not require an expect',
        build: () => SideEffectCounterCubit(repository),
        act: (cubit) => cubit.increment(),
        verify: (_) async {
          verify(() => repository.sideEffect()).called(1);
        },
      );
    });

    group('ExceptionCubit', () {
      final exception = Exception('oops');

      blocTest<ExceptionCubit, int>(
        'errors supports matchers',
        build: () => ExceptionCubit(),
        act: (cubit) => cubit.throwException(exception),
        errors: () => contains(exception),
      );

      blocTest<ExceptionCubit, int>(
        'captures uncaught exceptions',
        build: () => ExceptionCubit(),
        act: (cubit) => cubit.throwException(exception),
        errors: () => <Matcher>[equals(exception)],
      );

      blocTest<ExceptionCubit, int>(
        'captures calls to addError',
        build: () => ExceptionCubit(),
        // ignore: invalid_use_of_protected_member
        act: (cubit) => cubit.addError(exception),
        errors: () => <Matcher>[equals(exception)],
      );
    });

    group('ErrorCubit', () {
      final error = Error();

      blocTest<ErrorCubit, int>(
        'errors supports matchers',
        build: () => ErrorCubit(),
        act: (cubit) => cubit.throwError(error),
        errors: () => contains(error),
      );

      blocTest<ErrorCubit, int>(
        'captures uncaught errors',
        build: () => ErrorCubit(),
        act: (cubit) => cubit.throwError(error),
        errors: () => <Matcher>[equals(error)],
      );

      blocTest<ErrorCubit, int>(
        'captures calls to addError',
        build: () => ErrorCubit(),
        // ignore: invalid_use_of_protected_member
        act: (cubit) => cubit.addError(error),
        errors: () => <Matcher>[equals(error)],
      );
    });
  });
}
