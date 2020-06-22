import 'dart:async';

import 'package:bloc/bloc.dart';

typedef OnEventCallback = Function(CounterEvent);
typedef OnTransitionCallback = Function(Transition<CounterEvent, int>);
typedef OnErrorCallback = Function(Object error, StackTrace stackTrace);

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  final OnEventCallback onEventCallback;
  final OnTransitionCallback onTransitionCallback;
  final OnErrorCallback onErrorCallback;

  CounterBloc({
    this.onEventCallback,
    this.onTransitionCallback,
    this.onErrorCallback,
  }) : super(0);

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
    super.onEvent(event);
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    onTransitionCallback?.call(transition);
    super.onTransition(transition);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback?.call(error, stackTrace);
    super.onError(error, stackTrace);
  }
}
