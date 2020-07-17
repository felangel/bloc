import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'blocs.dart';

class DebounceCounterBloc extends Bloc<CounterEvent, int> {
  DebounceCounterBloc() : super(0);

  @override
  Stream<Transition<CounterEvent, int>> transformEvents(
    Stream<CounterEvent> events,
    TransitionFunction<CounterEvent, int> transitionFn,
  ) {
    return events
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap(transitionFn);
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
