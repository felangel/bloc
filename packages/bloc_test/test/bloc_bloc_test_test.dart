import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  group('blocTest', () {
    group('CounterBloc', () {
      blocTest<CounterBloc, int>(
        'emits [] when nothing is added',
        build: () async => CounterBloc(),
        expect: const <int>[],
      );

      blocTest<CounterBloc, int>(
        'emits [1] when CounterEvent.increment is added',
        build: () async => CounterBloc(),
        act: (bloc) async => bloc.add(CounterEvent.increment),
        expect: const <int>[1],
      );

      blocTest<CounterBloc, int>(
        'emits [1] when CounterEvent.increment is added with async act',
        build: () async => CounterBloc(),
        act: (bloc) async {
          await Future<void>.delayed(const Duration(seconds: 1));
          bloc.add(CounterEvent.increment);
        },
        expect: const <int>[1],
      );

      blocTest<CounterBloc, int>(
        'emits [1, 2] when CounterEvent.increment is called multiple times'
        'with async act',
        build: () async => CounterBloc(),
        act: (bloc) async {
          bloc.add(CounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(CounterEvent.increment);
        },
        expect: const <int>[1, 2],
      );

      blocTest<CounterBloc, int>(
        'emits [2] when CounterEvent.increment is added twice and skip: 1',
        build: () async => CounterBloc(),
        act: (bloc) async {
          bloc..add(CounterEvent.increment)..add(CounterEvent.increment);
        },
        skip: 1,
        expect: const <int>[2],
      );
    });

    group('AsyncCounterBloc', () {
      blocTest<AsyncCounterBloc, int>(
        'emits [] when nothing is added',
        build: () async => AsyncCounterBloc(),
        expect: const <int>[],
      );

      blocTest<AsyncCounterBloc, int>(
        'emits [1] when AsyncCounterEvent.increment is added',
        build: () async => AsyncCounterBloc(),
        act: (bloc) async => bloc.add(AsyncCounterEvent.increment),
        expect: const <int>[1],
      );

      blocTest<AsyncCounterBloc, int>(
        'emits [1, 2] when AsyncCounterEvent.increment is called multiple'
        'times with async act',
        build: () async => AsyncCounterBloc(),
        act: (bloc) async {
          bloc.add(AsyncCounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(AsyncCounterEvent.increment);
        },
        expect: const <int>[1, 2],
      );

      blocTest<AsyncCounterBloc, int>(
        'emits [2] when AsyncCounterEvent.increment is added twice and skip: 1',
        build: () async => AsyncCounterBloc(),
        act: (bloc) async => bloc
          ..add(AsyncCounterEvent.increment)
          ..add(AsyncCounterEvent.increment),
        skip: 1,
        expect: const <int>[2],
      );
    });

    group('DebounceCounterBloc', () {
      blocTest<DebounceCounterBloc, int>(
        'emits [] when nothing is added',
        build: () async => DebounceCounterBloc(),
        expect: const <int>[],
      );

      blocTest<DebounceCounterBloc, int>(
        'emits [1] when DebounceCounterEvent.increment is added',
        build: () async => DebounceCounterBloc(),
        act: (bloc) async => bloc.add(DebounceCounterEvent.increment),
        wait: const Duration(milliseconds: 300),
        expect: const <int>[1],
      );

      blocTest<DebounceCounterBloc, int>(
        'emits [2] when DebounceCounterEvent.increment '
        'is added twice and skip: 1',
        build: () async => DebounceCounterBloc(),
        act: (bloc) async {
          bloc.add(DebounceCounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 305));
          bloc.add(DebounceCounterEvent.increment);
        },
        skip: 1,
        wait: const Duration(milliseconds: 305),
        expect: const <int>[2],
      );
    });

    group('MultiCounterBloc', () {
      blocTest<MultiCounterBloc, int>(
        'emits [] when nothing is added',
        build: () async => MultiCounterBloc(),
        expect: const <int>[],
      );

      blocTest<MultiCounterBloc, int>(
        'emits [1, 2] when MultiCounterEvent.increment is added',
        build: () async => MultiCounterBloc(),
        act: (bloc) async => bloc.add(MultiCounterEvent.increment),
        expect: const <int>[1, 2],
      );

      blocTest<MultiCounterBloc, int>(
        'emits [1, 2, 3, 4] when MultiCounterEvent.increment is called'
        'multiple times with async act',
        build: () async => MultiCounterBloc(),
        act: (bloc) async {
          bloc.add(MultiCounterEvent.increment);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(MultiCounterEvent.increment);
        },
        expect: const <int>[1, 2, 3, 4],
      );

      blocTest<MultiCounterBloc, int>(
        'emits [4] when MultiCounterEvent.increment is added twice and skip: 3',
        build: () async => MultiCounterBloc(),
        act: (bloc) async => bloc
          ..add(MultiCounterEvent.increment)
          ..add(MultiCounterEvent.increment),
        skip: 3,
        expect: const <int>[4],
      );
    });

    group('ComplexBloc', () {
      blocTest<ComplexBloc, ComplexState>(
        'emits [] when nothing is added',
        build: () async => ComplexBloc(),
        expect: const <ComplexState>[],
      );

      blocTest<ComplexBloc, ComplexState>(
        'emits [ComplexStateB] when ComplexEventB is added',
        build: () async => ComplexBloc(),
        act: (bloc) async => bloc.add(ComplexEventB()),
        expect: <Matcher>[isA<ComplexStateB>()],
      );

      blocTest<ComplexBloc, ComplexState>(
        'emits [ComplexStateA] when [ComplexEventB, ComplexEventA] '
        'is added and skip: 1',
        build: () async => ComplexBloc(),
        act: (bloc) async => bloc..add(ComplexEventB())..add(ComplexEventA()),
        skip: 1,
        expect: <Matcher>[isA<ComplexStateA>()],
      );
    });

    group('ExceptionCounterBloc', () {
      blocTest<ExceptionCounterBloc, int>(
        'emits [] when nothing is added',
        build: () async => ExceptionCounterBloc(),
        expect: const <int>[],
      );

      blocTest<ExceptionCounterBloc, int>(
        'emits [2] when increment is added twice and skip: 1',
        build: () async => ExceptionCounterBloc(),
        act: (bloc) async => bloc
          ..add(ExceptionCounterEvent.increment)
          ..add(ExceptionCounterEvent.increment),
        skip: 1,
        expect: const <int>[2],
      );

      blocTest<ExceptionCounterBloc, int>(
        'emits [1] when increment is added',
        build: () async => ExceptionCounterBloc(),
        act: (bloc) async => bloc.add(ExceptionCounterEvent.increment),
        expect: const <int>[1],
      );

      blocTest<ExceptionCounterBloc, int>(
        'throws ExceptionCounterBlocException when increment is added',
        build: () async => ExceptionCounterBloc(),
        act: (bloc) async => bloc.add(ExceptionCounterEvent.increment),
        errors: <Matcher>[isA<ExceptionCounterBlocException>()],
      );

      blocTest<ExceptionCounterBloc, int>(
        'emits [1] and throws ExceptionCounterBlocException '
        'when increment is added',
        build: () async => ExceptionCounterBloc(),
        act: (bloc) async => bloc.add(ExceptionCounterEvent.increment),
        expect: const <int>[1],
        errors: <Matcher>[isA<ExceptionCounterBlocException>()],
      );

      blocTest<ExceptionCounterBloc, int>(
        'emits [1, 2] when increment is added twice',
        build: () async => ExceptionCounterBloc(),
        act: (bloc) async => bloc
          ..add(ExceptionCounterEvent.increment)
          ..add(ExceptionCounterEvent.increment),
        expect: const <int>[1, 2],
      );

      blocTest<ExceptionCounterBloc, int>(
        'throws two ExceptionCounterBlocExceptions '
        'when increment is added twice',
        build: () async => ExceptionCounterBloc(),
        act: (bloc) async => bloc
          ..add(ExceptionCounterEvent.increment)
          ..add(ExceptionCounterEvent.increment),
        errors: <Matcher>[
          isA<ExceptionCounterBlocException>(),
          isA<ExceptionCounterBlocException>(),
        ],
      );

      blocTest<ExceptionCounterBloc, int>(
        'emits [1, 2] and throws two ExceptionCounterBlocException '
        'when increment is added twice',
        build: () async => ExceptionCounterBloc(),
        act: (bloc) async => bloc
          ..add(ExceptionCounterEvent.increment)
          ..add(ExceptionCounterEvent.increment),
        expect: const <int>[1, 2],
        errors: <Matcher>[
          isA<ExceptionCounterBlocException>(),
          isA<ExceptionCounterBlocException>(),
        ],
      );
    });

    group('SideEffectCounterBloc', () {
      Repository repository;

      setUp(() {
        repository = MockRepository();
      });

      blocTest<SideEffectCounterBloc, int>(
        'emits [] when nothing is added',
        build: () async => SideEffectCounterBloc(repository),
        expect: const <int>[],
      );

      blocTest<SideEffectCounterBloc, int>(
        'emits [1] when SideEffectCounterEvent.increment is added',
        build: () async => SideEffectCounterBloc(repository),
        act: (bloc) async => bloc.add(SideEffectCounterEvent.increment),
        expect: const <int>[1],
        verify: (_) async {
          verify(repository.sideEffect()).called(1);
        },
      );

      blocTest<SideEffectCounterBloc, int>(
        'emits [2] when SideEffectCounterEvent.increment '
        'is added twice and skip: 1',
        build: () async => SideEffectCounterBloc(repository),
        act: (bloc) async => bloc
          ..add(SideEffectCounterEvent.increment)
          ..add(SideEffectCounterEvent.increment),
        skip: 1,
        expect: const <int>[2],
      );

      blocTest<SideEffectCounterBloc, int>(
        'does not require an expect',
        build: () async => SideEffectCounterBloc(repository),
        act: (bloc) async => bloc.add(SideEffectCounterEvent.increment),
        verify: (_) async {
          verify(repository.sideEffect()).called(1);
        },
      );
    });
  });
}
