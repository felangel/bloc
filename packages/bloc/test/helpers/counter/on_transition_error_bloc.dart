import 'dart:async';

import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class OnTransitionErrorBloc extends Bloc<CounterEvent, int> {
  final Function onErrorCallback;
  final Error error;

  OnTransitionErrorBloc({this.error, this.onErrorCallback});

  @override
  int get initialState => 0;

  @override
  void onError(Object error, StackTrace stacktrace) {
    onErrorCallback(error, stacktrace);
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    super.onTransition(transition);
    throw error;
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
      case CounterEvent.decrement:
        yield state - 1;
        break;
    }
  }
}
