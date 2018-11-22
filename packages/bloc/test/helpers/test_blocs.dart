import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

class SimpleBloc extends Bloc<dynamic, String> {
  @override
  String get initialState => '';

  @override
  Stream<String> mapEventToState(String state, dynamic event) {
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

abstract class BlocEvent {}

class EventA extends BlocEvent {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is EventA && runtimeType == other.runtimeType;

  @override
  int get hashCode => 4;
}

class EventB extends BlocEvent {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is EventB && runtimeType == other.runtimeType;

  @override
  int get hashCode => 5;
}

class EventC extends BlocEvent {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is EventC && runtimeType == other.runtimeType;

  @override
  int get hashCode => 6;
}

class ComplexBloc extends Bloc<BlocEvent, ComplexState> {
  ComplexState get initialState => ComplexStateA();

  @override
  Stream<BlocEvent> transform(Stream<BlocEvent> events) {
    return events.distinct();
  }

  @override
  Stream<ComplexState> mapEventToState(ComplexState state, BlocEvent event) {
    if (event is EventA) {
      return Observable.just(ComplexStateA());
    }
    if (event is EventB) {
      return Observable.just(ComplexStateB());
    }
    return Observable.just(ComplexStateC());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplexBloc &&
          runtimeType == other.runtimeType &&
          initialState == other.initialState;

  @override
  int get hashCode =>
      initialState.hashCode ^ mapEventToState.hashCode ^ transform.hashCode;
}

abstract class CounterEvent {}

class Increment extends CounterEvent {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is Increment && runtimeType == other.runtimeType;

  @override
  int get hashCode => 7;

  String toString() => 'Increment';
}

class Decrement extends CounterEvent {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is Decrement && runtimeType == other.runtimeType;

  @override
  int get hashCode => 8;

  @override
  String toString() => 'Decrement';
}

typedef OnTransitionCallback = Function(Transition<CounterEvent, int>);

class CounterBloc extends Bloc<CounterEvent, int> {
  int get initialState => 0;

  final OnTransitionCallback onTransitionCallback;

  CounterBloc([this.onTransitionCallback]);

  @override
  Stream<int> mapEventToState(int state, CounterEvent event) async* {
    if (event is Increment) {
      yield state + 1;
    }
    if (event is Decrement) {
      yield state - 1;
    }
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    onTransitionCallback(transition);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterBloc &&
          runtimeType == other.runtimeType &&
          initialState == other.initialState;

  @override
  int get hashCode =>
      initialState.hashCode ^ mapEventToState.hashCode ^ transform.hashCode;
}
