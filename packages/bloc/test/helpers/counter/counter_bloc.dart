import 'dart:async';

import 'package:bloc/bloc.dart';

typedef OnEventCallback = Function(CounterEvent);
typedef OnTransitionCallback = Function(Transition<CounterEvent, int>);
typedef OnErrorCallback = Function(Object error, StackTrace stacktrace);

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  int get initialState => 0;

  final OnEventCallback onEventCallback;
  final OnTransitionCallback onTransitionCallback;
  final OnErrorCallback onErrorCallback;

  CounterBloc({
    this.onEventCallback,
    this.onTransitionCallback,
    this.onErrorCallback,
  });

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }

  @override
  void onEvent(CounterEvent event) {
    onEventCallback?.call(event);
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    onTransitionCallback?.call(transition);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    onErrorCallback?.call(error, stacktrace);
  }
}
