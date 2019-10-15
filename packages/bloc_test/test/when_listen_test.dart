import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'helpers/helpers.dart';

class MockCounterBloc extends Mock implements CounterBloc {}

void main() {
  group('whenListen', () {
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

    test('can mock the stream of a bloc dependency', () {
      final counterBloc = MockCounterBloc();
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));
      final sumBloc = SumBloc(counterBloc);
      expectLater(sumBloc, emitsInOrder(<int>[0, 1, 3, 6]));
    });
  });
}
