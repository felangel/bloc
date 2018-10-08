import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';
import 'package:bloc/bloc.dart';

class SimpleBloc extends Bloc<String> {
  @override
  Stream<String> mapEventToState(event) {
    return Observable.just('data');
  }
}

abstract class ComplexState {}

class ComplexStateA extends ComplexState {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexStateA && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class ComplexStateB extends ComplexState {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexStateB && runtimeType == other.runtimeType;

  @override
  int get hashCode => 1;
}

class ComplexStateC extends ComplexState {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexStateC && runtimeType == other.runtimeType;

  @override
  int get hashCode => 2;
}

class ComplexStateUnknown extends ComplexState {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexStateUnknown && runtimeType == other.runtimeType;

  @override
  int get hashCode => 3;
}

class EventA {}

class EventB {}

class EventC {}

class ComplexBloc extends Bloc<ComplexState> {
  ComplexState get initialState => ComplexStateA();

  @override
  Stream<ComplexState> mapEventToState(event) {
    if (event is EventA) {
      return Observable.just(ComplexStateA());
    }
    if (event is EventB) {
      return Observable.just(ComplexStateB());
    }
    if (event is EventC) {
      return Observable.just(ComplexStateC());
    }
    return Observable.just(ComplexStateUnknown());
  }
}

void main() {
  group('Bloc Tests', () {
    group('Simple Bloc', () {
      SimpleBloc simpleBloc;

      setUp(() {
        simpleBloc = SimpleBloc();
      });

      test('dispose does not emit new states over the state stream', () {
        expectLater(
          simpleBloc.state,
          emitsInOrder([]),
        );

        simpleBloc.dispose();
      });

      test('initialState returns null when not implemented', () {
        expect(simpleBloc.initialState, null);
      });

      test('should map single event to correct state', () {
        expectLater(simpleBloc.state, emitsInOrder(['data']));

        simpleBloc.dispatch('event');
      });

      test('should map multiple events to correct states', () {
        expectLater(simpleBloc.state, emitsInOrder(['data', 'data', 'data']));

        simpleBloc.dispatch('event1');
        simpleBloc.dispatch('event2');
        simpleBloc.dispatch('event3');
      });
    });

    group('Complex Bloc', () {
      ComplexBloc complexBloc;

      setUp(() {
        complexBloc = ComplexBloc();
      });

      test('dispose does not emit new states over the state stream', () {
        expectLater(
          complexBloc.state,
          emitsInOrder([]),
        );

        complexBloc.dispose();
      });

      test('initialState returns ComplexStateA', () {
        expect(complexBloc.initialState, ComplexStateA());
      });

      test('should map single event to correct state', () {
        expectLater(complexBloc.state, emitsInOrder([ComplexStateA()]));

        complexBloc.dispatch(EventA());
      });

      test('should map multiple events to correct states', () {
        expectLater(
          complexBloc.state,
          emitsInOrder(
            [
              ComplexStateA(),
              ComplexStateB(),
              ComplexStateC(),
              ComplexStateUnknown(),
            ],
          ),
        );

        complexBloc.dispatch(EventA());
        complexBloc.dispatch(EventB());
        complexBloc.dispatch(EventC());
        complexBloc.dispatch(Error());
      });
    });
  });
}
