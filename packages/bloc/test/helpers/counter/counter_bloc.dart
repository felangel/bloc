import 'package:bloc/bloc.dart';

import './counter.dart';

typedef OnTransitionCallback = Function(Transition<CounterEvent, int>);

class CounterBloc extends Bloc<CounterEvent, int> {
  int get initialState => 0;

  final OnTransitionCallback onTransitionCallback;

  CounterBloc([this.onTransitionCallback]);

  @override
  Stream<int> mapEventToState(int currentState, CounterEvent event) async* {
    if (event is Increment) {
      yield currentState + 1;
    }
    if (event is Decrement) {
      yield currentState - 1;
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
