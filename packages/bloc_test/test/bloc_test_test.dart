import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'helpers/helpers.dart';

void main() {
  group('blocTest', () {
    group('CounterBloc', () {
      blocTest(
        'emits [0] when nothing is added',
        build: () => CounterBloc(),
        expect: [0],
      );

      blocTest(
        'emits [0, 1] when CounterEvent.increment is added',
        build: () => CounterBloc(),
        act: (bloc) => bloc.add(CounterEvent.increment),
        expect: [0, 1],
      );

      blocTest(
        'emits [0, 1] when CounterEvent.increment is added with async act',
        build: () => CounterBloc(),
        act: (bloc) async {
          await Future.delayed(Duration(seconds: 1));
          bloc.add(CounterEvent.increment);
        },
        expect: [0, 1],
      );

      blocTest(
        'emits [0, 1, 2] when CounterEvent.increment is called multiple times'
        'with async act',
        build: () => CounterBloc(),
        act: (bloc) async {
          bloc.add(CounterEvent.increment);
          await Future.delayed(Duration(milliseconds: 10));
          bloc.add(CounterEvent.increment);
        },
        expect: [0, 1, 2],
      );
    });

    group('AsyncCounterBloc', () {
      blocTest(
        'emits [0] when nothing is added',
        build: () => AsyncCounterBloc(),
        expect: [0],
      );

      blocTest(
        'emits [0, 1] when AsyncCounterEvent.increment is added',
        build: () => AsyncCounterBloc(),
        act: (bloc) => bloc.add(AsyncCounterEvent.increment),
        expect: [0, 1],
      );

      blocTest(
        'emits [0, 1, 2] when AsyncCounterEvent.increment is called multiple'
        'times with async act',
        build: () => AsyncCounterBloc(),
        act: (bloc) async {
          bloc.add(AsyncCounterEvent.increment);
          await Future.delayed(Duration(milliseconds: 10));
          bloc.add(AsyncCounterEvent.increment);
        },
        expect: [0, 1, 2],
      );
    });

    group('DebounceCounterBloc', () {
      blocTest(
        'emits [0] when nothing is added',
        build: () => DebounceCounterBloc(),
        expect: [0],
      );

      blocTest(
        'emits [0, 1] when DebounceCounterEvent.increment is added',
        build: () => DebounceCounterBloc(),
        act: (bloc) => bloc.add(DebounceCounterEvent.increment),
        wait: const Duration(milliseconds: 300),
        expect: [0, 1],
      );
    });

    group('MultiCounterBloc', () {
      blocTest(
        'emits [0] when nothing is added',
        build: () => MultiCounterBloc(),
        expect: [0],
      );

      blocTest(
        'emits [0, 1, 2] when MultiCounterEvent.increment is added',
        build: () => MultiCounterBloc(),
        act: (bloc) => bloc.add(MultiCounterEvent.increment),
        expect: [0, 1, 2],
      );

      blocTest(
        'emits [0, 1, 2, 3, 4] when MultiCounterEvent.increment is called'
        'multiple times with async act',
        build: () => MultiCounterBloc(),
        act: (bloc) async {
          bloc.add(MultiCounterEvent.increment);
          await Future.delayed(Duration(milliseconds: 10));
          bloc.add(MultiCounterEvent.increment);
        },
        expect: [0, 1, 2, 3, 4],
      );
    });

    group('ComplexBloc', () {
      blocTest(
        'emits [ComplexStateA] when nothing is added',
        build: () => ComplexBloc(),
        expect: [isA<ComplexStateA>()],
      );

      blocTest(
        'emits [ComplexStateA, ComplexStateB] when ComplexEventB is added',
        build: () => ComplexBloc(),
        act: (bloc) => bloc.add(ComplexEventB()),
        expect: [isA<ComplexStateA>(), isA<ComplexStateB>()],
      );
    });
  });
}
