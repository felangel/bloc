import 'dart:async';

import 'package:bloc/bloc.dart';
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
      when(() => counterBloc.state).thenReturn(10);
      expect(counterBloc.state, 10);
    });

    test('is compatible with listen', () {
      expect(
        counterBloc.stream.listen((_) {}),
        isA<StreamSubscription<dynamic>>(),
      );
    });

    test('is compatible with add', () {
      counterBloc.add(CounterEvent.increment);
    });

    test('is compatible with addError without StackTrace', () {
      // ignore: invalid_use_of_protected_member
      counterBloc.addError(Exception('oops'));
    });

    test('is compatible with addError with StackTrace', () {
      // ignore: invalid_use_of_protected_member
      counterBloc.addError(Exception('oops'), StackTrace.empty);
    });

    test('is compatible with onEvent', () {
      // ignore: invalid_use_of_protected_member
      counterBloc.onEvent(CounterEvent.increment);
    });

    test('is compatible with onError', () {
      // ignore: invalid_use_of_protected_member
      counterBloc.onError(Exception('oops'), StackTrace.empty);
    });

    test('is compatible with onTransition', () {
      // ignore: invalid_use_of_protected_member
      counterBloc.onTransition(
        const Transition(
          currentState: 0,
          event: CounterEvent.increment,
          nextState: 1,
        ),
      );
    });

    test('is compatible with close', () {
      expect(counterBloc.close(), completes);
    });

    test('is automatically compatible with whenListen', () {
      whenListen(
        counterBloc,
        Stream<int>.fromIterable([0, 1, 2, 3]),
      );
      expectLater(
        counterBloc.stream,
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
      when(() => counterCubit.state).thenReturn(10);
      expect(counterCubit.state, 10);
    });

    test('is automatically compatible with whenListen', () {
      whenListen(
        counterCubit,
        Stream<int>.fromIterable([0, 1, 2, 3]),
      );
      expectLater(
        counterCubit.stream,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
    });
  });
}
