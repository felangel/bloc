import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:test/test.dart';

import 'blocs/blocs.dart';
import 'cubits/cubits.dart';

class MockCounterBloc extends MockBloc<CounterEvent, int>
    implements CounterBloc {}

class MockCounterCubit extends MockCubit<int> implements CounterCubit {}

void main() {
  group('MockBloc', () {
    late CounterBloc counterBloc;

    setUp(() {
      counterBloc = MockCounterBloc();
    });

    test('is compatible with when', () {
      when(counterBloc).calls(#state).thenReturn(10);
      expect(counterBloc.state, 10);
    });

    test('is automatically compatible with whenListen', () {
      whenListen(
        counterBloc,
        Stream<int>.fromIterable([0, 1, 2, 3]),
      );
      expectLater(
        counterBloc,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
    });
  });

  group('MockCubit', () {
    late CounterCubit counterCubit;

    setUp(() {
      counterCubit = MockCounterCubit();
    });

    test('is compatible with when', () {
      when(counterCubit).calls(#state).thenReturn(10);
      expect(counterCubit.state, 10);
    });

    test('is automatically compatible with whenListen', () {
      whenListen(
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
