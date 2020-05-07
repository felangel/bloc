import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';
import 'helpers/helpers.dart';

class MockCounterBloc extends MockBloc<CounterEvent, int>
    implements CounterBloc {}

void main() {
  group('whenListen', () {
    test('can mock the stream of a single bloc with an empty Stream', () {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream<int>.empty());
      expectLater(
        counterBloc,
        emitsInOrder(<int>[]),
      );
    });

    test('can mock the stream of a single bloc', () {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      expectLater(
        counterBloc,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
    });

    test('can mock the stream of a single bloc with delays', () async {
      final counterBloc = MockCounterBloc();
      final controller = StreamController<int>();
      whenListen(counterBloc, controller.stream);
      expectLater(
        counterBloc,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      controller.add(0);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(1);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(2);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(3);
      controller.close();
    });

    test('can mock the stream of a single bloc with delays and skip(1)',
        () async {
      final counterBloc = MockCounterBloc();
      final controller = StreamController<int>();
      whenListen(counterBloc, controller.stream);
      expectLater(
        counterBloc.skip(1),
        emitsInOrder(
          <Matcher>[equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      controller.add(0);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(1);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(2);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(3);
      controller.close();
    });

    test('can mock the state of a single bloc with delays', () async {
      final counterBloc = MockCounterBloc();
      final controller = StreamController<int>();
      whenListen(counterBloc, controller.stream);
      expectLater(
        counterBloc,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      ).then((_) {
        expect(counterBloc.state, equals(3));
      });
      controller.add(0);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(1);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(2);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(3);
      controller.close();
    });

    test('can mock the state of a single bloc with delays and skip(1)',
        () async {
      final counterBloc = MockCounterBloc();
      final controller = StreamController<int>();
      whenListen(counterBloc, controller.stream);
      expectLater(
        counterBloc.skip(1),
        emitsInOrder(
          <Matcher>[equals(1), equals(2), equals(3), emitsDone],
        ),
      ).then((_) {
        expect(counterBloc.state, equals(3));
      });
      controller.add(0);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(1);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(2);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(3);
      controller.close();
    });

    test('can mock the state of a single bloc', () async {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      await expectLater(
        counterBloc,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      expect(counterBloc.state, equals(3));
    });

    test('can mock the stream of a single bloc as broadcast stream', () {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      expectLater(
        counterBloc,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      expectLater(
        counterBloc,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
    });

    test('can mock the stream of a single bloc as broadcast stream with skips',
        () {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      expectLater(
        counterBloc.skip(1),
        emitsInOrder(
          <Matcher>[equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      expectLater(
        counterBloc.skip(2),
        emitsInOrder(
          <Matcher>[equals(2), equals(3), emitsDone],
        ),
      );
    });

    test('can mock the stream of a single bloc with skip(1)', () {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      expectLater(
        counterBloc.skip(1),
        emitsInOrder(
          <Matcher>[equals(1), equals(2), equals(3), emitsDone],
        ),
      );
    });

    test('can mock the state of a single bloc with skip(1)', () async {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      await expectLater(
        counterBloc.skip(1),
        emitsInOrder(
          <Matcher>[equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      expect(counterBloc.state, equals(3));
    });

    test('can mock the state of a single bloc with skip(1).listen', () async {
      final counterBloc = MockCounterBloc();
      final states = <int>[];
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      counterBloc.skip(1).listen(states.add);
      await Future.delayed(Duration.zero);
      expect(states, [1, 2, 3]);
      expect(counterBloc.state, equals(3));
    });

    test('can mock the stream of a single bloc with skip(2)', () {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      expectLater(
        counterBloc.skip(2),
        emitsInOrder(
          <Matcher>[equals(2), equals(3), emitsDone],
        ),
      );
    });

    test('can mock the state of a single bloc with skip(2).listen', () async {
      final counterBloc = MockCounterBloc();
      final states = <int>[];
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      counterBloc.skip(2).listen(states.add);
      await Future.delayed(Duration.zero);
      expect(states, [2, 3]);
      expect(counterBloc.state, equals(3));
    });

    test('can mock the state of a single bloc with skip(2)', () async {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      await expectLater(
        counterBloc.skip(2),
        emitsInOrder(
          <Matcher>[equals(2), equals(3), emitsDone],
        ),
      );
      expect(counterBloc.state, equals(3));
    });

    test('can mock the state of a single bloc with skip(3).listen', () async {
      final counterBloc = MockCounterBloc();
      final states = <int>[];
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      counterBloc.skip(3).listen(states.add);
      await Future.delayed(Duration.zero);
      expect(states, [3]);
      expect(counterBloc.state, equals(3));
    });

    test('can mock the stream of a single bloc with skip(3)', () {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      expectLater(
        counterBloc.skip(3),
        emitsInOrder(
          <Matcher>[equals(3), emitsDone],
        ),
      );
    });

    test('can mock the state of a single bloc with skip(3)', () async {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      await expectLater(
        counterBloc.skip(3),
        emitsInOrder(
          <Matcher>[equals(3), emitsDone],
        ),
      );
      expect(counterBloc.state, equals(3));
    });

    test('can mock the stream of a bloc dependency', () {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      final sumBloc = SumBloc(counterBloc);
      expectLater(sumBloc, emitsInOrder(<int>[0, 1, 3, 6]));
    });

    test('can mock the state of a bloc dependency', () async {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      final sumBloc = SumBloc(counterBloc);
      await expectLater(sumBloc, emitsInOrder(<int>[0, 1, 3, 6]));
      expect(sumBloc.state, equals(6));
    });
  });
}
