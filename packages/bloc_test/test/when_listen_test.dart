import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

import 'cubits/cubits.dart';

class MockCounterCubit extends MockCubit<int> implements CounterCubit {}

void main() {
  group('whenListen', () {
    test('can mock the stream of a single cubit with an empty Stream', () {
      final counterCubit = MockCounterCubit();
      whenListen(counterCubit, const Stream<int>.empty());
      expectLater(counterCubit.stream, emitsInOrder(<int>[]));
    });

    test('can mock the stream of a single cubit', () async {
      final counterCubit = MockCounterCubit();
      whenListen(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      await expectLater(
        counterCubit.stream,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
    });

    test('can mock the stream of a single cubit with delays', () async {
      final counterCubit = MockCounterCubit();
      final controller = StreamController<int>();
      whenListen(counterCubit, controller.stream);
      unawaited(expectLater(
        counterCubit.stream,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      ));
      controller.add(0);
      await Future<void>.delayed(Duration.zero);
      controller.add(1);
      await Future<void>.delayed(Duration.zero);
      controller.add(2);
      await Future<void>.delayed(Duration.zero);
      controller.add(3);
      await controller.close();
    });

    test('can mock the state of a single cubit with delays', () async {
      final counterCubit = MockCounterCubit();
      final controller = StreamController<int>();
      whenListen(counterCubit, controller.stream);
      unawaited(expectLater(
        counterCubit.stream,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      ).then((dynamic _) {
        expect(counterCubit.state, equals(3));
      }));
      controller.add(0);
      await Future<void>.delayed(Duration.zero);
      controller.add(1);
      await Future<void>.delayed(Duration.zero);
      controller.add(2);
      await Future<void>.delayed(Duration.zero);
      controller.add(3);
      await controller.close();
    });

    test('can mock the state of a single cubit', () async {
      final counterCubit = MockCounterCubit();
      whenListen(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      await expectLater(
        counterCubit.stream,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      expect(counterCubit.state, equals(3));
    });

    test('can mock the initial state of a single cubit', () async {
      final counterCubit = MockCounterCubit();
      whenListen(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
        initialState: 0,
      );
      expect(counterCubit.state, equals(0));
      await expectLater(
        counterCubit.stream,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      expect(counterCubit.state, equals(3));
    });

    test('can mock the stream of a single cubit as broadcast stream', () {
      final counterCubit = MockCounterCubit();
      whenListen(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      expectLater(
        counterCubit.stream,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      expectLater(
        counterCubit.stream,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
    });

    test(
        'can mock the stream of a cubit dependency '
        '(with initial state)', () async {
      final controller = StreamController<int>();
      final counterCubit = MockCounterCubit();
      whenListen(counterCubit, controller.stream);
      final sumCubit = SumCubit(counterCubit);
      unawaited(expectLater(sumCubit.stream, emitsInOrder(<int>[0, 1, 3, 6])));
      controller..add(0)..add(1)..add(2)..add(3);
      await controller.close();
      expect(sumCubit.state, equals(6));
    });

    test('can mock the stream of a cubit dependency', () async {
      final controller = StreamController<int>();
      final counterCubit = MockCounterCubit();
      whenListen(counterCubit, controller.stream);
      final sumCubit = SumCubit(counterCubit);
      unawaited(expectLater(sumCubit.stream, emitsInOrder(<int>[1, 3, 6])));
      controller..add(1)..add(2)..add(3);
      await controller.close();
      expect(sumCubit.state, equals(6));
    });
  });

  group('whenListen (legacy)', () {
    test('can mock the stream of a single cubit with an empty Stream', () {
      final counterCubit = MockCounterCubit();
      final states = <int>[];
      whenListen(counterCubit, const Stream<int>.empty());
      // ignore: deprecated_member_use
      counterCubit.listen(states.add, onDone: () {
        expect(states, isEmpty);
      });
    });

    test('can mock the stream of a single cubit', () {
      final counterCubit = MockCounterCubit();
      final states = <int>[];
      whenListen(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      // ignore: deprecated_member_use
      counterCubit.listen(states.add, onDone: () {
        expect(states, equals([0, 1, 2, 3]));
      });
    });

    test('can mock the stream of a single cubit with delays', () async {
      final counterCubit = MockCounterCubit();
      final controller = StreamController<int>();
      final states = <int>[];
      whenListen(counterCubit, controller.stream);
      // ignore: deprecated_member_use
      counterCubit.listen(states.add, onDone: () {
        expect(states, equals([0, 1, 2, 3]));
      });
      controller.add(0);
      await Future<void>.delayed(Duration.zero);
      controller.add(1);
      await Future<void>.delayed(Duration.zero);
      controller.add(2);
      await Future<void>.delayed(Duration.zero);
      controller.add(3);
      await controller.close();
    });

    test('can mock the state of a single cubit with delays', () async {
      final counterCubit = MockCounterCubit();
      final controller = StreamController<int>();
      final states = <int>[];
      whenListen(counterCubit, controller.stream);
      // ignore: deprecated_member_use
      counterCubit.listen(states.add, onDone: () {
        expect(states, equals([0, 1, 2, 3]));
        expect(counterCubit.state, equals(3));
      });
      controller.add(0);
      await Future<void>.delayed(Duration.zero);
      controller.add(1);
      await Future<void>.delayed(Duration.zero);
      controller.add(2);
      await Future<void>.delayed(Duration.zero);
      controller.add(3);
      await controller.close();
    });

    test('can mock the state of a single cubit', () async {
      final counterCubit = MockCounterCubit();
      final states = <int>[];
      whenListen(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      // ignore: deprecated_member_use
      counterCubit.listen(states.add, onDone: () {
        expect(states, equals([0, 1, 2, 3]));
        expect(counterCubit.state, equals(3));
      });
    });

    test('can mock the initial state of a single cubit', () async {
      final counterCubit = MockCounterCubit();
      final states = <int>[];
      whenListen(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
        initialState: 0,
      );
      expect(counterCubit.state, equals(0));
      // ignore: deprecated_member_use
      counterCubit.listen(states.add, onDone: () {
        expect(states, equals([0, 1, 2, 3]));
        expect(counterCubit.state, equals(3));
      });
    });

    test('can mock the stream of a single cubit as broadcast stream', () {
      final counterCubit = MockCounterCubit();
      final statesA = <int>[];
      final statesB = <int>[];
      whenListen(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      counterCubit
        // ignore: deprecated_member_use
        ..listen(statesA.add, onDone: () {
          expect(statesA, equals([0, 1, 2, 3]));
          expect(counterCubit.state, equals(3));
        })
        // ignore: deprecated_member_use
        ..listen(statesB.add, onDone: () {
          expect(statesB, equals([0, 1, 2, 3]));
          expect(counterCubit.state, equals(3));
        });
    });

    test(
        'can mock the stream of a cubit dependency '
        '(with initial state)', () async {
      final controller = StreamController<int>();
      final counterCubit = MockCounterCubit();
      final states = <int>[];
      whenListen(counterCubit, controller.stream);
      final sumCubit = SumCubit(counterCubit);
      // ignore: deprecated_member_use
      sumCubit.listen(states.add, onDone: () {
        expect(states, equals([0, 1, 3, 6]));
        expect(sumCubit.state, equals(6));
      });
      controller..add(0)..add(1)..add(2)..add(3);
      await controller.close();
      expect(sumCubit.state, equals(6));
    });

    test('can mock the stream of a cubit dependency', () async {
      final controller = StreamController<int>();
      final counterCubit = MockCounterCubit();
      final states = <int>[];
      whenListen(counterCubit, controller.stream);
      final sumCubit = SumCubit(counterCubit);
      // ignore: deprecated_member_use
      sumCubit.listen(states.add, onDone: () {
        expect(states, equals([1, 3, 6]));
        expect(sumCubit.state, equals(6));
      });
      controller..add(1)..add(2)..add(3);
      await controller.close();
      expect(sumCubit.state, equals(6));
    });
  });
}
