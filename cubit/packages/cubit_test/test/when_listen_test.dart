import 'dart:async';

import 'package:cubit_test/cubit_test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';
import 'helpers/helpers.dart';

class MockCounterCubit extends MockCubit<int> implements CounterCubit {}

void main() {
  group('whenListen', () {
    test('can mock the stream of a single cubit with an empty Stream', () {
      final counterCubit = MockCounterCubit();
      whenListen<CounterCubit, int>(counterCubit, const Stream<int>.empty());
      expectLater(counterCubit, emitsInOrder(<int>[]));
    });

    test('can mock the stream of a single cubit', () {
      final counterCubit = MockCounterCubit();
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      expectLater(
        counterCubit,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
    });

    test('can mock the stream of a single cubit with delays', () async {
      final counterCubit = MockCounterCubit();
      final controller = StreamController<int>();
      whenListen<CounterCubit, int>(counterCubit, controller.stream);
      unawaited(expectLater(
        counterCubit,
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

    test('can mock the stream of a single cubit with delays and skip(1)',
        () async {
      final counterCubit = MockCounterCubit();
      final controller = StreamController<int>();
      whenListen<CounterCubit, int>(counterCubit, controller.stream);
      unawaited(expectLater(
        counterCubit.skip(1),
        emitsInOrder(
          <Matcher>[equals(1), equals(2), equals(3), emitsDone],
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
      whenListen<CounterCubit, int>(counterCubit, controller.stream);
      unawaited(expectLater(
        counterCubit,
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

    test('can mock the state of a single cubit with delays and skip(1)',
        () async {
      final counterCubit = MockCounterCubit();
      final controller = StreamController<int>();
      whenListen<CounterCubit, int>(counterCubit, controller.stream);
      unawaited(expectLater(
        counterCubit.skip(1),
        emitsInOrder(
          <Matcher>[equals(1), equals(2), equals(3), emitsDone],
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
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      await expectLater(
        counterCubit,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      expect(counterCubit.state, equals(3));
    });

    test('can mock the stream of a single cubit as broadcast stream', () {
      final counterCubit = MockCounterCubit();
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      expectLater(
        counterCubit,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      expectLater(
        counterCubit,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
    });

    test('can mock the stream of a single cubit as broadcast stream with skips',
        () {
      final counterCubit = MockCounterCubit();
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      expectLater(
        counterCubit.skip(1),
        emitsInOrder(
          <Matcher>[equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      expectLater(
        counterCubit.skip(2),
        emitsInOrder(
          <Matcher>[equals(2), equals(3), emitsDone],
        ),
      );
    });

    test('can mock the stream of a single cubit with skip(1)', () {
      final counterCubit = MockCounterCubit();
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      expectLater(
        counterCubit.skip(1),
        emitsInOrder(
          <Matcher>[equals(1), equals(2), equals(3), emitsDone],
        ),
      );
    });

    test('can mock the state of a single cubit with skip(1)', () async {
      final counterCubit = MockCounterCubit();
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      await expectLater(
        counterCubit.skip(1),
        emitsInOrder(
          <Matcher>[equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      expect(counterCubit.state, equals(3));
    });

    test('can mock the state of a single cubit with skip(1).listen', () async {
      final counterCubit = MockCounterCubit();
      final states = <int>[];
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      counterCubit.skip(1).listen(states.add);
      await Future<void>.delayed(Duration.zero);
      expect(states, [1, 2, 3]);
      expect(counterCubit.state, equals(3));
    });

    test('can mock the stream of a single cubit with skip(2)', () {
      final counterCubit = MockCounterCubit();
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      expectLater(
        counterCubit.skip(2),
        emitsInOrder(
          <Matcher>[equals(2), equals(3), emitsDone],
        ),
      );
    });

    test('can mock the state of a single cubit with skip(2).listen', () async {
      final counterCubit = MockCounterCubit();
      final states = <int>[];
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      counterCubit.skip(2).listen(states.add);
      await Future<void>.delayed(Duration.zero);
      expect(states, [2, 3]);
      expect(counterCubit.state, equals(3));
    });

    test('can mock the state of a single cubit with skip(2)', () async {
      final counterCubit = MockCounterCubit();
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      await expectLater(
        counterCubit.skip(2),
        emitsInOrder(
          <Matcher>[equals(2), equals(3), emitsDone],
        ),
      );
      expect(counterCubit.state, equals(3));
    });

    test('can mock the state of a single cubit with skip(3).listen', () async {
      final counterCubit = MockCounterCubit();
      final states = <int>[];
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      counterCubit.skip(3).listen(states.add);
      await Future<void>.delayed(Duration.zero);
      expect(states, [3]);
      expect(counterCubit.state, equals(3));
    });

    test('can mock the stream of a single cubit with skip(3)', () {
      final counterCubit = MockCounterCubit();
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      expectLater(
        counterCubit.skip(3),
        emitsInOrder(
          <Matcher>[equals(3), emitsDone],
        ),
      );
    });

    test('can mock the state of a single cubit with skip(3)', () async {
      final counterCubit = MockCounterCubit();
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );
      await expectLater(
        counterCubit.skip(3),
        emitsInOrder(
          <Matcher>[equals(3), emitsDone],
        ),
      );
      expect(counterCubit.state, equals(3));
    });

    test('can mock the stream of a cubit dependency', () async {
      final controller = StreamController<int>();
      final counterCubit = MockCounterCubit();
      whenListen<CounterCubit, int>(counterCubit, controller.stream);
      final sumCubit = SumCubit(counterCubit);
      unawaited(expectLater(sumCubit, emitsInOrder(<int>[0, 1, 3, 6])));
      controller..add(0)..add(1)..add(2)..add(3);
      await controller.close();
    });

    test('can mock the state of a cubit dependency', () async {
      final controller = StreamController<int>();
      final counterCubit = MockCounterCubit();
      whenListen<CounterCubit, int>(counterCubit, controller.stream);
      final sumCubit = SumCubit(counterCubit);
      unawaited(expectLater(sumCubit, emitsInOrder(<int>[0, 1, 3, 6])));
      controller..add(0)..add(1)..add(2)..add(3);
      await controller.close();
      expect(sumCubit.state, equals(6));
    });
  });
}
