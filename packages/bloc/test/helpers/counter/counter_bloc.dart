import 'package:bloc/bloc.dart';

typedef OnTransitionCallback = Function(Transition<CounterEvent, int>);

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  int get initialState => 0;

  final OnTransitionCallback onTransitionCallback;

  CounterBloc([this.onTransitionCallback]);

  @override
  Stream<int> mapEventToState(int currentState, CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
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
