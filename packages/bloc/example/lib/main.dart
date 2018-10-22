import 'dart:async';

import 'package:bloc/bloc.dart';

abstract class CounterEvent {}

class IncrementCounter extends CounterEvent {}

class DecrementCounter extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  int get initialState => 0;

  void increment() {
    dispatch(IncrementCounter());
  }

  void decrement() {
    dispatch(DecrementCounter());
  }

  @override
  Stream<int> mapEventToState(int state, CounterEvent event) async* {
    print('event: ${event.runtimeType}');

    if (event is IncrementCounter) {
      yield state + 1;
    }
    if (event is DecrementCounter) {
      yield state - 1;
    }
  }
}

void main() async {
  final counterBloc = CounterBloc();

  counterBloc.state.listen((state) {
    print('state: ${state.toString()}');
  });

  print('initialState: ${counterBloc.initialState}');

  // Increment Phase
  counterBloc.dispatch(IncrementCounter());
  await Future<void>.delayed(Duration(seconds: 1));

  counterBloc.dispatch(IncrementCounter());
  await Future<void>.delayed(Duration(seconds: 1));

  counterBloc.dispatch(IncrementCounter());
  await Future<void>.delayed(Duration(seconds: 1));

  // Decrement Phase
  counterBloc.dispatch(DecrementCounter());
  await Future<void>.delayed(Duration(seconds: 1));

  counterBloc.dispatch(DecrementCounter());
  await Future<void>.delayed(Duration(seconds: 1));

  counterBloc.dispatch(DecrementCounter());
  await Future<void>.delayed(Duration(seconds: 1));
}
