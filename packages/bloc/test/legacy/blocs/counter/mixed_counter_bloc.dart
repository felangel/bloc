import 'dart:async';

import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class MixedCounterBloc extends Bloc<CounterEvent, int> {
  MixedCounterBloc() : super(0) {
    on<CounterEvent>((event, emit) => emit(_mapEventToState(event)));
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    yield _mapEventToState(event);
  }

  int _mapEventToState(CounterEvent event) {
    switch (event) {
      case CounterEvent.increment:
        return state + 1;
      case CounterEvent.decrement:
        return state - 1;
    }
  }
}
