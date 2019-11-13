import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';

import 'package:test/test.dart';

import 'helpers/counter_bloc.dart';

class MockCounterBloc extends MockBloc<CounterEvent, int>
    implements CounterBloc {}

void main() {
  group('MockBloc', () {
    CounterBloc counterBloc;

    setUp(() {
      counterBloc = MockCounterBloc();
    });

    test('is compatible with skip', () {
      expect(counterBloc.skip(1) is Stream<int>, isTrue);
    });

    test('is compatible with when', () {
      when(counterBloc.state).thenReturn(10);
      expect(counterBloc.state, 10);
    });

    test('is automatically compatible with whenListen', () {
      whenListen(counterBloc, Stream<int>.fromIterable([0, 1, 2, 3]));
      expectLater(
        counterBloc,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
    });
  });
}
