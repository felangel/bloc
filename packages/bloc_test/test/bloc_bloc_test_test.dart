import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  group('blocTest', () {
    group('CounterBloc', () {
      blocTest<CounterBloc, int>(
        'emits [] when nothing is added',
        build: () => CounterBloc(),
        expect: const <int>[],
      );

      blocTest<CounterBloc, int>(
        'emits [1] when CounterEvent.increment is added',
        build: () => CounterBloc(),
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: const <int>[1],
      );

      blocTest<CounterBloc, int>(
        'emits [1] when CounterEvent.increment is added with async act',
        build: () => CounterBloc(),
        act: (bloc) async {
          await Future<void>.delayed(const Duration(seconds: 1));
          bloc.add(CounterEvent.increment);
        },
        expect: const <int>[1],
      );

      blocTest<CounterBloc, int>(
        'emits [1, 2] when CounterEvent.increment is called multiple times '
        'with async act',
        build: () => CounterBloc(),
        act: (bloc) async {
          bloc.add(CounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(CounterEvent.increment);
        },
        expect: const <int>[1, 2],
      );

      blocTest<CounterBloc, int>(
        'emits [2] when CounterEvent.increment is added twice and skip: 1',
        build: () => CounterBloc(),
        act: (bloc) {
          bloc..add(CounterEvent.increment)..add(CounterEvent.increment);
        },
        skip: 1,
        expect: const <int>[2],
      );

      blocTest<CounterBloc, int>(
        'emits [11] when CounterEvent.increment is added and emitted 10',
        build: () => CounterBloc()..emit(10),
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: const <int>[11],
      );

      blocTest<CounterBloc, int>(
        'emits [11] when CounterEvent.increment is added and seed 10',
        build: () => CounterBloc(),
        seed: 10,
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: const <int>[11],
      );

      test('fails immediately when expectation is incorrect', () async {
        const expectedError = '''Expected: [2]
  Actual: [1]
   Which: at location [0] is <1> instead of <2>
''';
        late Object actualError;
        final completer = Completer<void>();
        await runZonedGuarded(() async {
          unawaited(testBloc<CounterBloc, int>(
            build: () => CounterBloc(),
            act: (bloc) => bloc.add(CounterEvent.increment),
            expect: const <int>[2],
          ).then((_) => completer.complete()));
          await completer.future;
        }, (Object error, _) {
          actualError = error;
          completer.complete();
        });
        expect((actualError as TestFailure).message, expectedError);
      });
    });

    group('AsyncCounterBloc', () {
      blocTest<AsyncCounterBloc, int>(
        'emits [] when nothing is added',
        build: () => AsyncCounterBloc(),
        expect: const <int>[],
      );

      blocTest<AsyncCounterBloc, int>(
        'emits [1] when CounterEvent.increment is added',
        build: () => AsyncCounterBloc(),
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: const <int>[1],
      );

      blocTest<AsyncCounterBloc, int>(
        'emits [1, 2] when CounterEvent.increment is called multiple'
        'times with async act',
        build: () => AsyncCounterBloc(),
        act: (bloc) async {
          bloc.add(CounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(CounterEvent.increment);
        },
        expect: const <int>[1, 2],
      );

      blocTest<AsyncCounterBloc, int>(
        'emits [2] when CounterEvent.increment is added twice and skip: 1',
        build: () => AsyncCounterBloc(),
        act: (bloc) =>
            bloc..add(CounterEvent.increment)..add(CounterEvent.increment),
        skip: 1,
        expect: const <int>[2],
      );

      blocTest<AsyncCounterBloc, int>(
        'emits [11] when CounterEvent.increment is added and emitted 10',
        build: () => AsyncCounterBloc()..emit(10),
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: const <int>[11],
      );
    });

    group('DebounceCounterBloc', () {
      blocTest<DebounceCounterBloc, int>(
        'emits [] when nothing is added',
        build: () => DebounceCounterBloc(),
        expect: const <int>[],
      );

      blocTest<DebounceCounterBloc, int>(
        'emits [1] when CounterEvent.increment is added',
        build: () => DebounceCounterBloc(),
        act: (bloc) => bloc.add(CounterEvent.increment),
        wait: const Duration(milliseconds: 300),
        expect: const <int>[1],
      );

      blocTest<DebounceCounterBloc, int>(
        'emits [2] when CounterEvent.increment '
        'is added twice and skip: 1',
        build: () => DebounceCounterBloc(),
        act: (bloc) async {
          bloc.add(CounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 305));
          bloc.add(CounterEvent.increment);
        },
        skip: 1,
        wait: const Duration(milliseconds: 300),
        expect: const <int>[2],
      );

      blocTest<DebounceCounterBloc, int>(
        'emits [11] when CounterEvent.increment is added and emitted 10',
        build: () => DebounceCounterBloc()..emit(10),
        act: (bloc) => bloc.add(CounterEvent.increment),
        wait: const Duration(milliseconds: 300),
        expect: const <int>[11],
      );
    });

    group('InstanceEmitBloc', () {
      blocTest<InstantEmitBloc, int>(
        'emits [1] when nothing is added',
        build: () => InstantEmitBloc(),
        expect: const <int>[1],
      );

      blocTest<InstantEmitBloc, int>(
        'emits [1, 2] when CounterEvent.increment is added',
        build: () => InstantEmitBloc(),
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: const <int>[1, 2],
      );

      blocTest<InstantEmitBloc, int>(
        'emits [1, 2, 3] when CounterEvent.increment is called'
        'multiple times with async act',
        build: () => InstantEmitBloc(),
        act: (bloc) async {
          bloc.add(CounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(CounterEvent.increment);
        },
        expect: const <int>[1, 2, 3],
      );

      blocTest<InstantEmitBloc, int>(
        'emits [3] when CounterEvent.increment is added twice and skip: 2',
        build: () => InstantEmitBloc(),
        act: (bloc) =>
            bloc..add(CounterEvent.increment)..add(CounterEvent.increment),
        skip: 2,
        expect: const <int>[3],
      );

      blocTest<InstantEmitBloc, int>(
        'emits [11, 12] when CounterEvent.increment is added and emitted 10',
        build: () => InstantEmitBloc()..emit(10),
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: const <int>[11, 12],
      );
    });

    group('MultiCounterBloc', () {
      blocTest<MultiCounterBloc, int>(
        'emits [] when nothing is added',
        build: () => MultiCounterBloc(),
        expect: const <int>[],
      );

      blocTest<MultiCounterBloc, int>(
        'emits [1, 2] when CounterEvent.increment is added',
        build: () => MultiCounterBloc(),
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: const <int>[1, 2],
      );

      blocTest<MultiCounterBloc, int>(
        'emits [1, 2, 3, 4] when CounterEvent.increment is called'
        'multiple times with async act',
        build: () => MultiCounterBloc(),
        act: (bloc) async {
          bloc.add(CounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(CounterEvent.increment);
        },
        expect: const <int>[1, 2, 3, 4],
      );

      blocTest<MultiCounterBloc, int>(
        'emits [4] when CounterEvent.increment is added twice and skip: 3',
        build: () => MultiCounterBloc(),
        act: (bloc) =>
            bloc..add(CounterEvent.increment)..add(CounterEvent.increment),
        skip: 3,
        expect: const <int>[4],
      );

      blocTest<MultiCounterBloc, int>(
        'emits [11, 12] when CounterEvent.increment is added and emitted 10',
        build: () => MultiCounterBloc()..emit(10),
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: const <int>[11, 12],
      );
    });

    group('ComplexBloc', () {
      blocTest<ComplexBloc, ComplexState>(
        'emits [] when nothing is added',
        build: () => ComplexBloc(),
        expect: const <ComplexState>[],
      );

      blocTest<ComplexBloc, ComplexState>(
        'emits [ComplexStateB] when ComplexEventB is added',
        build: () => ComplexBloc(),
        act: (bloc) => bloc.add(ComplexEventB()),
        expect: <Matcher>[isA<ComplexStateB>()],
      );

      blocTest<ComplexBloc, ComplexState>(
        'emits [ComplexStateA] when [ComplexEventB, ComplexEventA] '
        'is added and skip: 1',
        build: () => ComplexBloc(),
        act: (bloc) => bloc..add(ComplexEventB())..add(ComplexEventA()),
        skip: 1,
        expect: <Matcher>[isA<ComplexStateA>()],
      );
    });

    group('ExceptionCounterBloc', () {
      blocTest<ExceptionCounterBloc, int>(
        'emits [] when nothing is added',
        build: () => ExceptionCounterBloc(),
        expect: const <int>[],
      );

      blocTest<ExceptionCounterBloc, int>(
        'emits [2] when increment is added twice and skip: 1',
        build: () => ExceptionCounterBloc(),
        act: (bloc) =>
            bloc..add(CounterEvent.increment)..add(CounterEvent.increment),
        skip: 1,
        expect: const <int>[2],
      );

      blocTest<ExceptionCounterBloc, int>(
        'emits [1] when increment is added',
        build: () => ExceptionCounterBloc(),
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: const <int>[1],
      );

      blocTest<ExceptionCounterBloc, int>(
        'throws ExceptionCounterBlocException when increment is added',
        build: () => ExceptionCounterBloc(),
        act: (bloc) => bloc.add(CounterEvent.increment),
        errors: <Matcher>[isA<ExceptionCounterBlocException>()],
      );

      blocTest<ExceptionCounterBloc, int>(
        'emits [1] and throws ExceptionCounterBlocException '
        'when increment is added',
        build: () => ExceptionCounterBloc(),
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: const <int>[1],
        errors: <Matcher>[isA<ExceptionCounterBlocException>()],
      );

      blocTest<ExceptionCounterBloc, int>(
        'emits [1, 2] when increment is added twice',
        build: () => ExceptionCounterBloc(),
        act: (bloc) =>
            bloc..add(CounterEvent.increment)..add(CounterEvent.increment),
        expect: const <int>[1, 2],
      );

      blocTest<ExceptionCounterBloc, int>(
        'throws two ExceptionCounterBlocExceptions '
        'when increment is added twice',
        build: () => ExceptionCounterBloc(),
        act: (bloc) =>
            bloc..add(CounterEvent.increment)..add(CounterEvent.increment),
        errors: <Matcher>[
          isA<ExceptionCounterBlocException>(),
          isA<ExceptionCounterBlocException>(),
        ],
      );

      blocTest<ExceptionCounterBloc, int>(
        'emits [1, 2] and throws two ExceptionCounterBlocException '
        'when increment is added twice',
        build: () => ExceptionCounterBloc(),
        act: (bloc) =>
            bloc..add(CounterEvent.increment)..add(CounterEvent.increment),
        expect: const <int>[1, 2],
        errors: <Matcher>[
          isA<ExceptionCounterBlocException>(),
          isA<ExceptionCounterBlocException>(),
        ],
      );
    });

    group('SideEffectCounterBloc', () {
      late Repository repository;

      setUp(() {
        repository = MockRepository();
        when(repository).calls(#sideEffect).thenReturn(null);
      });

      blocTest<SideEffectCounterBloc, int>(
        'emits [] when nothing is added',
        build: () => SideEffectCounterBloc(repository),
        expect: const <int>[],
      );

      blocTest<SideEffectCounterBloc, int>(
        'emits [1] when CounterEvent.increment is added',
        build: () => SideEffectCounterBloc(repository),
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: const <int>[1],
        verify: (_) {
          verify(repository).called(#sideEffect).once();
        },
      );

      blocTest<SideEffectCounterBloc, int>(
        'emits [2] when CounterEvent.increment '
        'is added twice and skip: 1',
        build: () => SideEffectCounterBloc(repository),
        act: (bloc) =>
            bloc..add(CounterEvent.increment)..add(CounterEvent.increment),
        skip: 1,
        expect: const <int>[2],
      );

      blocTest<SideEffectCounterBloc, int>(
        'does not require an expect',
        build: () => SideEffectCounterBloc(repository),
        act: (bloc) => bloc.add(CounterEvent.increment),
        verify: (_) {
          verify(repository).called(#sideEffect).times(1);
        },
      );

      blocTest<SideEffectCounterBloc, int>(
        'async verify',
        build: () => SideEffectCounterBloc(repository),
        act: (bloc) => bloc.add(CounterEvent.increment),
        verify: (_) async {
          await Future<void>.delayed(Duration.zero);
          verify(repository).called(#sideEffect).once();
        },
      );

      test('fails immediately when verify is incorrect', () async {
        const expectedError =
            '''Expected MockRepository.sideEffect() to be called <2> time(s) but actual call count was <1>.''';
        late Object actualError;
        final completer = Completer<void>();
        await runZonedGuarded(() async {
          unawaited(testBloc<SideEffectCounterBloc, int>(
            build: () => SideEffectCounterBloc(repository),
            act: (bloc) => bloc.add(CounterEvent.increment),
            verify: (_) {
              verify(repository).called(#sideEffect).times(2);
            },
          ).then((_) => completer.complete()));
          await completer.future;
        }, (Object error, _) {
          actualError = error;
          completer.complete();
        });
        expect((actualError as MocktailFailure).message, expectedError);
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
          unawaited(testBloc<ComplexBloc, ComplexState>(
            build: () => ComplexBloc(),
            act: (bloc) => bloc.add(ComplexEventA()),
            expect: <ComplexState>[ComplexStateA()],
          ).then((_) => completer.complete()));
          await completer.future;
        }, (Object error, _) {
          actualError = error;
          completer.complete();
        });
        expect((actualError as TestFailure).message, expectedError);
      });
    });
  });
}
