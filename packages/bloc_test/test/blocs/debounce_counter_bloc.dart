import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

enum DebounceCounterEvent { increment }

class DebounceCounterBloc extends Bloc<DebounceCounterEvent, int> {
  DebounceCounterBloc() : super(0);

  @override
  Stream<Transition<DebounceCounterEvent, int>> transformEvents(
    Stream<DebounceCounterEvent> events,
    TransitionFunction<DebounceCounterEvent, int> transitionFn,
  ) {
    return events
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap(transitionFn);
  }

  @override
  Stream<int> mapEventToState(
    DebounceCounterEvent event,
  ) async* {
    switch (event) {
      case DebounceCounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
