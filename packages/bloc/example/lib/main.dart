import 'dart:async';

import 'package:bloc/bloc.dart';

abstract class CounterEvent {}

class IncrementCounter extends CounterEvent {
  @override
  String toString() => 'IncrementCounter';
}

class DecrementCounter extends CounterEvent {
  @override
  String toString() => 'DecrementCounter';
}

class CounterBloc extends Bloc<CounterEvent, int> {
  void increment() {
    dispatch(IncrementCounter());
  }

  void decrement() {
    dispatch(DecrementCounter());
  }

  @override
  int get initialState => 0;

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    print(transition.toString());
  }

  @override
  Stream<int> mapEventToState(int state, CounterEvent event) async* {
    if (event is IncrementCounter) {
      /// Simulating Network Latency etc...
      await Future<void>.delayed(Duration(seconds: 1));
      yield state + 1;
    }
    if (event is DecrementCounter) {
      /// Simulating Network Latency etc...
      await Future<void>.delayed(Duration(milliseconds: 500));
      yield state - 1;
    }
  }
}

void main() async {
  final counterBloc = CounterBloc();

  // Increment Phase
  counterBloc.dispatch(IncrementCounter());
  counterBloc.dispatch(IncrementCounter());
  counterBloc.dispatch(IncrementCounter());

  // Decrement Phase
  counterBloc.dispatch(DecrementCounter());
  counterBloc.dispatch(DecrementCounter());
  counterBloc.dispatch(DecrementCounter());
}
