import 'dart:async';

import 'package:cubit_test/cubit_test.dart';
import 'package:mockito/mockito.dart';

import 'package:test/test.dart';

import 'helpers/counter_cubit.dart';

class MockCounterCubit extends MockCubit<int> implements CounterCubit {}

void main() {
  group('MockCubit', () {
    CounterCubit counterCubit;

    setUp(() {
      counterCubit = MockCounterCubit();
    });

    test('is compatible with skip', () {
      expect(counterCubit.skip(1) is Stream<int>, isTrue);
    });

    test('is compatible with when', () {
      when(counterCubit.state).thenReturn(10);
      expect(counterCubit.state, 10);
    });

    test('is automatically compatible with whenListen', () {
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream<int>.fromIterable([0, 1, 2, 3]),
      );
      expectLater(
        counterCubit,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
    });
  });
}
