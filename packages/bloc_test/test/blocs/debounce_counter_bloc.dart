import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'blocs.dart';

EventTransformer<E> debounce<E>() {
  return (events, mapper) {
    return events
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap(mapper);
  };
}

class DebounceCounterBloc extends Bloc<CounterEvent, int> {
  DebounceCounterBloc() : super(0) {
    on<CounterEvent>(
      (event, emit) {
        switch (event) {
          case CounterEvent.increment:
            return emit(state + 1);
        }
      },
      transformer: debounce(),
    );
  }
}
