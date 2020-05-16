import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'helpers/helpers.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  group('blocTest', () {
    group('CounterBloc', () {
      blocTest(
        'emits [] when nothing is added',
        build: () async => CounterBloc(),
        expect: [],
      );

      blocTest(
        'emits [0] when nothing is added and skip: 0',
        build: () async => CounterBloc(),
        skip: 0,
        expect: [0],
      );

      blocTest(
        'emits [1] when CounterEvent.increment is added',
        build: () async => CounterBloc(),
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: [1],
      );

      blocTest(
        'emits [1] when CounterEvent.increment is added with async act',
        build: () async => CounterBloc(),
        act: (bloc) async {
          await Future.delayed(Duration(seconds: 1));
          bloc.add(CounterEvent.increment);
        },
        expect: [1],
      );

      blocTest(
        'emits [1, 2] when CounterEvent.increment is called multiple times'
        'with async act',
        build: () async => CounterBloc(),
        act: (bloc) async {
          bloc.add(CounterEvent.increment);
          await Future.delayed(Duration(milliseconds: 10));
          bloc.add(CounterEvent.increment);
        },
        expect: [1, 2],
      );
    });

    group('AsyncCounterBloc', () {
      blocTest(
        'emits [] when nothing is added',
        build: () async => AsyncCounterBloc(),
        expect: [],
      );

      blocTest(
        'emits [0] when nothing is added and skip: 0',
        build: () async => AsyncCounterBloc(),
        skip: 0,
        expect: [0],
      );

      blocTest(
        'emits [1] when AsyncCounterEvent.increment is added',
        build: () async => AsyncCounterBloc(),
        act: (bloc) => bloc.add(AsyncCounterEvent.increment),
        expect: [1],
      );

      blocTest(
        'emits [1, 2] when AsyncCounterEvent.increment is called multiple'
        'times with async act',
        build: () async => AsyncCounterBloc(),
        act: (bloc) async {
          bloc.add(AsyncCounterEvent.increment);
          await Future.delayed(Duration(milliseconds: 10));
          bloc.add(AsyncCounterEvent.increment);
        },
        expect: [1, 2],
      );
    });

    group('DebounceCounterBloc', () {
      blocTest(
        'emits [] when nothing is added',
        build: () async => DebounceCounterBloc(),
        expect: [],
      );

      blocTest(
        'emits [0] when nothing is added and skip: 0',
        build: () async => DebounceCounterBloc(),
        skip: 0,
        expect: [0],
      );

      blocTest(
        'emits [1] when DebounceCounterEvent.increment is added',
        build: () async => DebounceCounterBloc(),
        act: (bloc) => bloc.add(DebounceCounterEvent.increment),
        wait: const Duration(milliseconds: 300),
        expect: [1],
      );
    });

    group('MultiCounterBloc', () {
      blocTest(
        'emits [] when nothing is added',
        build: () async => MultiCounterBloc(),
        expect: [],
      );

      blocTest(
        'emits [0] when nothing is added and skip: 0',
        build: () async => MultiCounterBloc(),
        skip: 0,
        expect: [0],
      );

      blocTest(
        'emits [1, 2] when MultiCounterEvent.increment is added',
        build: () async => MultiCounterBloc(),
        act: (bloc) => bloc.add(MultiCounterEvent.increment),
        expect: [1, 2],
      );

      blocTest(
        'emits [1, 2, 3, 4] when MultiCounterEvent.increment is called'
        'multiple times with async act',
        build: () async => MultiCounterBloc(),
        act: (bloc) async {
          bloc.add(MultiCounterEvent.increment);
          await Future.delayed(Duration(milliseconds: 10));
          bloc.add(MultiCounterEvent.increment);
        },
        expect: [1, 2, 3, 4],
      );
    });

    group('ComplexBloc', () {
      blocTest(
        'emits [] when nothing is added',
        build: () async => ComplexBloc(),
        expect: [],
      );

      blocTest(
        'emits [ComplexStateA] when nothing is added and skip: 0',
        build: () async => ComplexBloc(),
        skip: 0,
        expect: [isA<ComplexStateA>()],
      );

      blocTest(
        'emits [ComplexStateB] when ComplexEventB is added',
        build: () async => ComplexBloc(),
        act: (bloc) => bloc.add(ComplexEventB()),
        expect: [isA<ComplexStateB>()],
      );
    });

    group('ExceptionCounterBloc', () {
      blocTest(
        'emits [] when nothing is added',
        build: () async => ExceptionCounterBloc(),
        expect: [],
      );

      blocTest(
        'emits [0] when nothing is added and skip: 0',
        build: () async => ExceptionCounterBloc(),
        skip: 0,
        expect: [0],
      );

      blocTest(
        'emits [1] when increment is added',
        build: () async => ExceptionCounterBloc(),
        act: (bloc) => bloc.add(ExceptionCounterEvent.increment),
        expect: [1],
      );

      blocTest(
        'throws ExceptionCounterBlocException when increment is added',
        build: () async => ExceptionCounterBloc(),
        act: (bloc) => bloc.add(ExceptionCounterEvent.increment),
        errors: [
          isA<ExceptionCounterBlocException>(),
        ],
      );

      blocTest(
        'emits [1] and throws ExceptionCounterBlocException '
        'when increment is added',
        build: () async => ExceptionCounterBloc(),
        act: (bloc) => bloc.add(ExceptionCounterEvent.increment),
        expect: [1],
        errors: [
          isA<ExceptionCounterBlocException>(),
        ],
      );

      blocTest(
        'emits [1, 2] when increment is added twice',
        build: () async => ExceptionCounterBloc(),
        act: (bloc) async => bloc
          ..add(ExceptionCounterEvent.increment)
          ..add(ExceptionCounterEvent.increment),
        expect: [1, 2],
      );

      blocTest(
        'throws two ExceptionCounterBlocExceptions '
        'when increment is added twice',
        build: () async => ExceptionCounterBloc(),
        act: (bloc) async => bloc
          ..add(ExceptionCounterEvent.increment)
          ..add(ExceptionCounterEvent.increment),
        errors: [
          isA<ExceptionCounterBlocException>(),
          isA<ExceptionCounterBlocException>(),
        ],
      );

      blocTest(
        'emits [1, 2] and throws two ExceptionCounterBlocException '
        'when increment is added twice',
        build: () async => ExceptionCounterBloc(),
        act: (bloc) async => bloc
          ..add(ExceptionCounterEvent.increment)
          ..add(ExceptionCounterEvent.increment),
        expect: [1, 2],
        errors: [
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

      blocTest(
        'emits [] when nothing is added',
        build: () async => SideEffectCounterBloc(repository),
        expect: [],
      );

      blocTest(
        'emits [0] when nothing is added and skip: 0',
        build: () async => SideEffectCounterBloc(repository),
        skip: 0,
        expect: [0],
      );

      blocTest(
        'emits [1] when SideEffectCounterEvent.increment is added',
        build: () async => SideEffectCounterBloc(repository),
        act: (bloc) => bloc.add(SideEffectCounterEvent.increment),
        expect: [1],
        verify: (_) async {
          verify(repository.sideEffect()).called(1);
        },
      );

      blocTest(
        'does not require an expect',
        build: () async => SideEffectCounterBloc(repository),
        act: (bloc) => bloc.add(SideEffectCounterEvent.increment),
        verify: (_) async {
          verify(repository.sideEffect()).called(1);
        },
      );
    });
  });
}
