import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:test/test.dart';

import 'blocs/blocs.dart';
import 'cubits/cubits.dart' hide ComplexState, ComplexStateA, ComplexStateB;

class MockCounterBloc extends MockBloc<CounterEvent, int>
    implements CounterBloc {}

class MockComplexBloc extends MockBloc<ComplexEvent, ComplexState>
    implements ComplexBloc {}

class MockCounterCubit extends MockCubit<int> implements CounterCubit {}

void main() {
  group('MockBloc', () {
    late CounterBloc counterBloc;
    late ComplexBloc complexBloc;

    setUp(() {
      counterBloc = MockCounterBloc();
      complexBloc = MockComplexBloc();
    });

    test('is compatible with when', () {
      when(() => counterBloc.state).thenReturn(10);
      when(() => complexBloc.state).thenReturn(ComplexStateB());

      expect(counterBloc.state, 10);
      expect(complexBloc.state, isA<ComplexStateB>());
    });

    test('is compatible with emit', () {
      // ignore: invalid_use_of_internal_member
      counterBloc.emit(10);
      // ignore: invalid_use_of_internal_member
      complexBloc.emit(ComplexStateB());
    });

    test('is compatible with add', () {
      counterBloc.add(CounterEvent.increment);
      complexBloc.add(ComplexEventB());
    });

    test('is compatible with addError without StackTrace', () {
      counterBloc.addError(Exception('oops'));
      complexBloc.addError(Exception('oops'));
    });

    test('is compatible with addError with StackTrace', () {
      counterBloc.addError(Exception('oops'), StackTrace.empty);
      complexBloc.addError(Exception('oops'), StackTrace.empty);
    });

    test('is compatible with onEvent', () {
      // ignore: invalid_use_of_protected_member
      counterBloc.onEvent(CounterEvent.increment);
      // ignore: invalid_use_of_protected_member
      complexBloc.onEvent(ComplexEventB());
    });

    test('is compatible with onError', () {
      // ignore: invalid_use_of_protected_member
      counterBloc.onError(Exception('oops'), StackTrace.empty);
      // ignore: invalid_use_of_protected_member
      complexBloc.onError(Exception('oops'), StackTrace.empty);
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
      // ignore: invalid_use_of_protected_member
      complexBloc.onTransition(
        Transition(
          currentState: ComplexStateA(),
          event: ComplexEventB(),
          nextState: ComplexStateB(),
        ),
      );
    });

    test('is compatible with close', () {
      expect(counterBloc.close(), completes);
      expect(complexBloc.close(), completes);
    });

    test('is automatically compatible with whenListen', () {
      whenListen(
        counterBloc,
        Stream<int>.fromIterable([0, 1, 2, 3]),
      );
      whenListen(
        complexBloc,
        Stream<ComplexState>.fromIterable([ComplexStateA(), ComplexStateB()]),
      );
      expectLater(
        counterBloc.stream,
        emitsInOrder(
          <Matcher>[equals(0), equals(1), equals(2), equals(3), emitsDone],
        ),
      );
      expectLater(
        complexBloc.stream,
        emitsInOrder(
          <Matcher>[isA<ComplexStateA>(), isA<ComplexStateB>(), emitsDone],
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
