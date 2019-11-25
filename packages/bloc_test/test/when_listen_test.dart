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

    test('can mock the stream of a bloc dependency', () {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      final sumBloc = SumBloc(counterBloc);
      expectLater(sumBloc, emitsInOrder(<int>[0, 1, 3, 6]));
    });
  });
}
