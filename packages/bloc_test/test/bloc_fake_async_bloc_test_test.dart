import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

class MockRepository extends Mock implements Repository {}

void unawaited(Future<void>? _) {}

void main() {
  group('blocTest', () {
    group('CounterBloc', () {
      fakeAsyncBlocTest<CounterBloc, int>(
        'supports matchers (contains)',
        build: () => CounterBloc(),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => contains(1),
      );

      fakeAsyncBlocTest<CounterBloc, int>(
        'supports matchers (containsAll)',
        build: () => CounterBloc(),
        act: (bloc, fakeAsync) => bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        expect: () => containsAll(<int>[2, 1]),
      );

      fakeAsyncBlocTest<CounterBloc, int>(
        'supports matchers (containsAllInOrder)',
        build: () => CounterBloc(),
        act: (bloc, fakeAsync) => bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        expect: () => containsAllInOrder(<int>[1, 2]),
      );

      fakeAsyncBlocTest<CounterBloc, int>(
        'emits [] when nothing is added',
        build: () => CounterBloc(),
        expect: () => const <int>[],
      );

      fakeAsyncBlocTest<CounterBloc, int>(
        'emits [1] when CounterEvent.increment is added',
        build: () => CounterBloc(),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => const <int>[1],
      );

      fakeAsyncBlocTest<CounterBloc, int>(
        'emits [1] when CounterEvent.increment is added with async act',
        build: () => CounterBloc(),
        act: (bloc, fakeAsync) async {
          fakeAsync.elapse(const Duration(seconds: 1));
          bloc.add(CounterEvent.increment);
        },
        expect: () => const <int>[1],
      );

      fakeAsyncBlocTest<CounterBloc, int>(
        'emits [1, 2] when CounterEvent.increment is called multiple times '
        'with async act',
        build: () => CounterBloc(),
        act: (bloc, fakeAsync) async {
          bloc.add(CounterEvent.increment);
          fakeAsync.elapse(const Duration(milliseconds: 10));
          bloc.add(CounterEvent.increment);
        },
        expect: () => const <int>[1, 2],
      );

      fakeAsyncBlocTest<CounterBloc, int>(
        'emits [2] when CounterEvent.increment is added twice and skip: 1',
        build: () => CounterBloc(),
        act: (bloc, fakeAsync) {
          bloc
            ..add(CounterEvent.increment)
            ..add(CounterEvent.increment);
        },
        skip: 1,
        expect: () => const <int>[2],
      );

      fakeAsyncBlocTest<CounterBloc, int>(
        'emits [11] when CounterEvent.increment is added and emitted 10',
        build: () => CounterBloc(),
        seed: () => 10,
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => const <int>[11],
      );

      fakeAsyncBlocTest<CounterBloc, int>(
        'emits [11] when CounterEvent.increment is added and seed 10',
        build: () => CounterBloc(),
        seed: () => 10,
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => const <int>[11],
      );

      test('fails immediately when expectation is incorrect', () async {
        const expectedError = 'Expected: [2]\n'
            '  Actual: [1]\n'
            '   Which: at location [0] is <1> instead of <2>\n'
            '\n'
            '==== diff ========================================\n'
            '\n'
            '''\x1B[90m[\x1B[0m\x1B[31m[-2-]\x1B[0m\x1B[32m{+1+}\x1B[0m\x1B[90m]\x1B[0m\n'''
            '\n'
            '==== end diff ====================================\n'
            '';
        late Object actualError;
        final completer = Completer<void>();
        await runZonedGuarded(() async {
          unawaited(Future.delayed(
              Duration.zero,
              () => testBlocFakeAsync<CounterBloc, int>(
                    build: () => CounterBloc(),
                    act: (bloc, f) => bloc.add(CounterEvent.increment),
                    expect: () => const <int>[2],
                  )).then((_) => completer.complete()));
          await completer.future;
        }, (Object error, _) {
          actualError = error;
          if (!completer.isCompleted) completer.complete();
        });
        expect((actualError as TestFailure).message, expectedError);
      });

      test('fails immediately when uncaught exception occurs within bloc',
          () async {
        late Object? actualError;
        final completer = Completer<void>();
        await runZonedGuarded(() async {
          unawaited(Future.delayed(
              Duration.zero,
              () => testBlocFakeAsync<ErrorCounterBloc, int>(
                    build: () => ErrorCounterBloc(),
                    act: (bloc, f) => bloc.add(CounterEvent.increment),
                    expect: () => const <int>[1],
                  )).then((_) => completer.complete()));
          await completer.future;
        }, (Object error, _) {
          actualError = error;
        });
        expect(actualError, isA<ErrorCounterBlocError>());
      });

      test('fails immediately when exception occurs in act', () async {
        final exception = Exception('oops');
        Object? actualError;
        final completer = Completer<void>();

        await runZonedGuarded(() async {
          unawaited(Future.delayed(
              Duration.zero,
              () => testBlocFakeAsync<ErrorCounterBloc, int>(
                    build: () => ErrorCounterBloc(),
                    act: (_, f) => throw exception,
                    expect: () => const <int>[1],
                  )).then((_) => completer.complete()));
          await completer.future;
        }, (Object error, _) {
          actualError = error;
          if (!completer.isCompleted) completer.complete();
        });
        expect(actualError, exception);
      });
    });

    group('AsyncCounterBloc', () {
      fakeAsyncBlocTest<AsyncCounterBloc, int>(
        'emits [] when nothing is added',
        build: () => AsyncCounterBloc(),
        expect: () => const <int>[],
      );

      fakeAsyncBlocTest<AsyncCounterBloc, int>(
        'emits [1] when CounterEvent.increment is added',
        build: () => AsyncCounterBloc(),
        act: (bloc, fakeAsync) {
          bloc.add(CounterEvent.increment);
          fakeAsync.elapse(const Duration(milliseconds: 10));
        },
        expect: () => const <int>[1],
      );

      fakeAsyncBlocTest<AsyncCounterBloc, int>(
        'emits [1, 2] when CounterEvent.increment is called multiple'
        'times with async act',
        build: () => AsyncCounterBloc(),
        act: (bloc, fakeAsync) {
          bloc.add(CounterEvent.increment);
          fakeAsync.elapse(const Duration(milliseconds: 10));
          bloc.add(CounterEvent.increment);
          fakeAsync.elapse(const Duration(milliseconds: 10));
        },
        expect: () => const <int>[1, 2],
      );

      fakeAsyncBlocTest<AsyncCounterBloc, int>(
        'emits [2] when CounterEvent.increment is added twice and skip: 1',
        build: () => AsyncCounterBloc(),
        act: (bloc, fakeAsync) {
          bloc
            ..add(CounterEvent.increment)
            ..add(CounterEvent.increment);
          fakeAsync.elapse(const Duration(milliseconds: 10));
        },
        skip: 1,
        expect: () => const <int>[2],
      );

      fakeAsyncBlocTest<AsyncCounterBloc, int>(
        'emits [11] when CounterEvent.increment is added and emitted 10',
        build: () => AsyncCounterBloc(),
        seed: () => 10,
        act: (bloc, fakeAsync) {
          bloc.add(CounterEvent.increment);
          fakeAsync.elapse(const Duration(milliseconds: 10));
        },
        expect: () => const <int>[11],
      );
    });

    group('DebounceCounterBloc', () {
      fakeAsyncBlocTest<DebounceCounterBloc, int>(
        'emits [] when nothing is added',
        build: () => DebounceCounterBloc(),
        expect: () => const <int>[],
      );

      fakeAsyncBlocTest<DebounceCounterBloc, int>(
        'emits [1] when CounterEvent.increment is added',
        build: () => DebounceCounterBloc(),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        wait: const Duration(milliseconds: 300),
        expect: () => const <int>[1],
      );

      fakeAsyncBlocTest<DebounceCounterBloc, int>(
        'emits [2] when CounterEvent.increment '
        'is added twice and skip: 1',
        build: () => DebounceCounterBloc(),
        act: (bloc, fakeAsync) async {
          bloc.add(CounterEvent.increment);
          fakeAsync.elapse(const Duration(milliseconds: 305));
          bloc.add(CounterEvent.increment);
        },
        skip: 1,
        wait: const Duration(milliseconds: 300),
        expect: () => const <int>[2],
      );

      fakeAsyncBlocTest<DebounceCounterBloc, int>(
        'emits [11] when CounterEvent.increment is added and emitted 10',
        build: () => DebounceCounterBloc(),
        seed: () => 10,
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        wait: const Duration(milliseconds: 300),
        expect: () => const <int>[11],
      );
    });

    group('InstantEmitBloc', () {
      fakeAsyncBlocTest<InstantEmitBloc, int>(
        'emits [1] when nothing is added',
        build: () => InstantEmitBloc(),
        expect: () => const <int>[1],
      );

      fakeAsyncBlocTest<InstantEmitBloc, int>(
        'emits [1, 2] when CounterEvent.increment is added',
        build: () => InstantEmitBloc(),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => const <int>[1, 2],
      );

      fakeAsyncBlocTest<InstantEmitBloc, int>(
        'emits [1, 2, 3] when CounterEvent.increment is called'
        'multiple times with async act',
        build: () => InstantEmitBloc(),
        act: (bloc, fakeAsync) async {
          bloc.add(CounterEvent.increment);
          fakeAsync.elapse(const Duration(milliseconds: 10));
          bloc.add(CounterEvent.increment);
        },
        expect: () => const <int>[1, 2, 3],
      );

      fakeAsyncBlocTest<InstantEmitBloc, int>(
        'emits [3] when CounterEvent.increment is added twice and skip: 2',
        build: () => InstantEmitBloc(),
        act: (bloc, fakeAsync) => bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        skip: 2,
        expect: () => const <int>[3],
      );

      fakeAsyncBlocTest<InstantEmitBloc, int>(
        'emits [11, 12] when CounterEvent.increment is added and seeded 10',
        build: () => InstantEmitBloc(),
        seed: () => 10,
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => const <int>[11, 12],
      );
    });

    group('MultiCounterBloc', () {
      fakeAsyncBlocTest<MultiCounterBloc, int>(
        'emits [] when nothing is added',
        build: () => MultiCounterBloc(),
        expect: () => const <int>[],
      );

      fakeAsyncBlocTest<MultiCounterBloc, int>(
        'emits [1, 2] when CounterEvent.increment is added',
        build: () => MultiCounterBloc(),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => const <int>[1, 2],
      );

      fakeAsyncBlocTest<MultiCounterBloc, int>(
        'emits [1, 2, 3, 4] when CounterEvent.increment is called'
        'multiple times with async act',
        build: () => MultiCounterBloc(),
        act: (bloc, fakeAsync) {
          bloc.add(CounterEvent.increment);
          fakeAsync.elapse(const Duration(milliseconds: 10));
          bloc.add(CounterEvent.increment);
        },
        expect: () => const <int>[1, 2, 3, 4],
      );

      fakeAsyncBlocTest<MultiCounterBloc, int>(
        'emits [4] when CounterEvent.increment is added twice and skip: 3',
        build: () => MultiCounterBloc(),
        act: (bloc, fakeAsync) => bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        skip: 3,
        expect: () => const <int>[4],
      );

      fakeAsyncBlocTest<MultiCounterBloc, int>(
        'emits [11, 12] when CounterEvent.increment is added and emitted 10',
        build: () => MultiCounterBloc(),
        seed: () => 10,
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => const <int>[11, 12],
      );
    });

    group('ComplexBloc', () {
      fakeAsyncBlocTest<ComplexBloc, ComplexState>(
        'emits [] when nothing is added',
        build: () => ComplexBloc(),
        expect: () => const <ComplexState>[],
      );

      fakeAsyncBlocTest<ComplexBloc, ComplexState>(
        'emits [ComplexStateB] when ComplexEventB is added',
        build: () => ComplexBloc(),
        act: (bloc, fakeAsync) => bloc.add(ComplexEventB()),
        expect: () => [isA<ComplexStateB>()],
      );

      fakeAsyncBlocTest<ComplexBloc, ComplexState>(
        'emits [ComplexStateA] when [ComplexEventB, ComplexEventA] '
        'is added and skip: 1',
        build: () => ComplexBloc(),
        act: (bloc, fakeAsync) => bloc
          ..add(ComplexEventB())
          ..add(ComplexEventA()),
        skip: 1,
        expect: () => [isA<ComplexStateA>()],
      );
    });
    group('ErrorCounterBloc', () {
      fakeAsyncBlocTest<ErrorCounterBloc, int>(
        'emits [] when nothing is added',
        build: () => ErrorCounterBloc(),
        expect: () => const <int>[],
      );

      fakeAsyncBlocTest<ErrorCounterBloc, int>(
        'emits [2] when increment is added twice and skip: 1',
        build: () => ErrorCounterBloc(),
        act: (bloc, fakeAsync) => bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        skip: 1,
        expect: () => const <int>[2],
        errors: () => isNotEmpty,
      );

      fakeAsyncBlocTest<ErrorCounterBloc, int>(
        'emits [1] when increment is added',
        build: () => ErrorCounterBloc(),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => const <int>[1],
        errors: () => isNotEmpty,
      );

      fakeAsyncBlocTest<ErrorCounterBloc, int>(
        'throws ErrorCounterBlocException when increment is added',
        build: () => ErrorCounterBloc(),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        errors: () => [isA<ErrorCounterBlocError>()],
      );

      fakeAsyncBlocTest<ErrorCounterBloc, int>(
        'emits [1] and throws ErrorCounterBlocError '
        'when increment is added',
        build: () => ErrorCounterBloc(),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => const <int>[1],
        errors: () => [isA<ErrorCounterBlocError>()],
      );

      fakeAsyncBlocTest<ErrorCounterBloc, int>(
        'emits [] and throws ErrorCounterBlocError '
        'when ErrorCounterBlocError thrown in act',
        build: () => ErrorCounterBloc(),
        act: (bloc, fakeAsync) => throw ErrorCounterBlocError(),
        expect: () => const <int>[],
        errors: () => [isA<ErrorCounterBlocError>()],
      );

      fakeAsyncBlocTest<ErrorCounterBloc, int>(
        'emits [1, 2] when increment is added twice',
        build: () => ErrorCounterBloc(),
        act: (bloc, fakeAsync) => bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        expect: () => const <int>[1, 2],
        errors: () => isNotEmpty,
      );

      fakeAsyncBlocTest<ErrorCounterBloc, int>(
        'throws two ErrorCounterBlocErrors '
        'when increment is added twice',
        build: () => ErrorCounterBloc(),
        act: (bloc, fakeAsync) => bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        errors: () => [
          isA<ErrorCounterBlocError>(),
          isA<ErrorCounterBlocError>(),
        ],
      );

      fakeAsyncBlocTest<ErrorCounterBloc, int>(
        'emits [1, 2] and throws two ErrorCounterBlocErrors '
        'when increment is added twice',
        build: () => ErrorCounterBloc(),
        act: (bloc, fakeAsync) => bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        expect: () => const <int>[1, 2],
        errors: () => [
          isA<ErrorCounterBlocError>(),
          isA<ErrorCounterBlocError>(),
        ],
      );
    });

    group('ExceptionCounterBloc', () {
      fakeAsyncBlocTest<ExceptionCounterBloc, int>(
        'emits [] when nothing is added',
        build: () => ExceptionCounterBloc(),
        expect: () => const <int>[],
      );

      fakeAsyncBlocTest<ExceptionCounterBloc, int>(
        'emits [2] when increment is added twice and skip: 1',
        build: () => ExceptionCounterBloc(),
        act: (bloc, fakeAsync) => bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        skip: 1,
        expect: () => const <int>[2],
        errors: () => isNotEmpty,
      );

      fakeAsyncBlocTest<ExceptionCounterBloc, int>(
        'emits [1] when increment is added',
        build: () => ExceptionCounterBloc(),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => const <int>[1],
        errors: () => isNotEmpty,
      );

      fakeAsyncBlocTest<ExceptionCounterBloc, int>(
        'throws ExceptionCounterBlocException when increment is added',
        build: () => ExceptionCounterBloc(),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        errors: () => [isA<ExceptionCounterBlocException>()],
      );

      fakeAsyncBlocTest<ExceptionCounterBloc, int>(
        'emits [1] and throws ExceptionCounterBlocException '
        'when increment is added',
        build: () => ExceptionCounterBloc(),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => const <int>[1],
        errors: () => [isA<ExceptionCounterBlocException>()],
      );

      fakeAsyncBlocTest<ExceptionCounterBloc, int>(
        'emits [1, 2] when increment is added twice',
        build: () => ExceptionCounterBloc(),
        act: (bloc, fakeAsync) => bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        expect: () => const <int>[1, 2],
        errors: () => isNotEmpty,
      );

      fakeAsyncBlocTest<ExceptionCounterBloc, int>(
        'throws two ExceptionCounterBlocExceptions '
        'when increment is added twice',
        build: () => ExceptionCounterBloc(),
        act: (bloc, fakeAsync) => bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        errors: () => [
          isA<ExceptionCounterBlocException>(),
          isA<ExceptionCounterBlocException>(),
        ],
      );

      fakeAsyncBlocTest<ExceptionCounterBloc, int>(
        'emits [1, 2] and throws two ExceptionCounterBlocException '
        'when increment is added twice',
        build: () => ExceptionCounterBloc(),
        act: (bloc, fakeAsync) => bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        expect: () => const <int>[1, 2],
        errors: () => [
          isA<ExceptionCounterBlocException>(),
          isA<ExceptionCounterBlocException>(),
        ],
      );
    });

    group('SideEffectCounterBloc', () {
      late Repository repository;

      setUp(() {
        repository = MockRepository();
        when(() => repository.sideEffect()).thenReturn(null);
      });

      fakeAsyncBlocTest<SideEffectCounterBloc, int>(
        'emits [] when nothing is added',
        build: () => SideEffectCounterBloc(repository),
        expect: () => const <int>[],
      );

      fakeAsyncBlocTest<SideEffectCounterBloc, int>(
        'emits [1] when CounterEvent.increment is added',
        build: () => SideEffectCounterBloc(repository),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => const <int>[1],
        verify: (_) {
          verify(() => repository.sideEffect()).called(1);
        },
      );

      fakeAsyncBlocTest<SideEffectCounterBloc, int>(
        'emits [2] when CounterEvent.increment '
        'is added twice and skip: 1',
        build: () => SideEffectCounterBloc(repository),
        act: (bloc, fakeAsync) => bloc
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment),
        skip: 1,
        expect: () => const <int>[2],
      );

      fakeAsyncBlocTest<SideEffectCounterBloc, int>(
        'does not require an expect',
        build: () => SideEffectCounterBloc(repository),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        verify: (_) {
          verify(() => repository.sideEffect()).called(1);
        },
      );

      fakeAsyncBlocTest<SideEffectCounterBloc, int>(
        'async verify',
        build: () => SideEffectCounterBloc(repository),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        verify: (_) async {
          await Future<void>.delayed(Duration.zero);
          verify(() => repository.sideEffect()).called(1);
        },
      );

      fakeAsyncBlocTest<SideEffectCounterBloc, int>(
        'setUp is executed before build/act',
        setUp: (fakeAsync) {
          when(() => repository.sideEffect()).thenThrow(Exception());
        },
        build: () => SideEffectCounterBloc(repository),
        act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
        expect: () => const <int>[],
        errors: () => [isException],
      );

      test('fails immediately when verify is incorrect', () async {
        const expectedError =
            '''Expected: <2>\n  Actual: <1>\nUnexpected number of calls\n''';
        late Object actualError;
        final completer = Completer<void>();
        await runZonedGuarded(() async {
          unawaited(Future.delayed(
              Duration.zero,
              () => testBlocFakeAsync<SideEffectCounterBloc, int>(
                    build: () => SideEffectCounterBloc(repository),
                    act: (bloc, f) => bloc.add(CounterEvent.increment),
                    verify: (_) {
                      verify(() => repository.sideEffect()).called(2);
                    },
                  )).then((_) => completer.complete()));
          await completer.future;
        }, (Object error, _) {
          actualError = error;
          if (!completer.isCompleted) completer.complete();
        });
        expect((actualError as TestFailure).message, expectedError);
      });

      test('shows equality warning when strings are identical', () async {
        const expectedError = '''Expected: [Instance of \'ComplexStateA\']
  Actual: [Instance of \'ComplexStateA\']
   Which: at location [0] is <Instance of \'ComplexStateA\'> instead of <Instance of \'ComplexStateA\'>\n
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the blocTest rather than concrete state instances.\n''';
        late Object actualError;
        final completer = Completer<void>();
        await runZonedGuarded(() async {
          unawaited(Future.delayed(
              Duration.zero,
              () => testBlocFakeAsync<ComplexBloc, ComplexState>(
                    build: () => ComplexBloc(),
                    act: (bloc, fakeAsync) => bloc.add(ComplexEventA()),
                    expect: () => <ComplexState>[ComplexStateA()],
                  )).then((_) => completer.complete()));
          await completer.future;
        }, (Object error, _) {
          actualError = error;
          completer.complete();
        });
        expect((actualError as TestFailure).message, expectedError);
      });
    });
  });

  group('tearDown', () {
    late int tearDownCallCount;
    int? state;

    setUp(() {
      tearDownCallCount = 0;
    });

    tearDown(() {
      expect(tearDownCallCount, equals(1));
    });

    fakeAsyncBlocTest<CounterBloc, int>(
      'is called after the test is run',
      build: () => CounterBloc(),
      act: (bloc, fakeAsync) => bloc.add(CounterEvent.increment),
      verify: (bloc) {
        state = bloc.state;
      },
      tearDown: (fakeAsync) {
        tearDownCallCount++;
        expect(state, equals(1));
      },
    );
  });
}
