import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

enum DebounceCounterEvent { increment }

class DebounceCounterBloc extends Bloc<DebounceCounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> transformEvents(
    Stream<DebounceCounterEvent> events,
    Stream<int> Function(DebounceCounterEvent event) next,
  ) {
    return events
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap(next);
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
