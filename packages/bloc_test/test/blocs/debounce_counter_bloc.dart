import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'blocs.dart';

const _debounceDuration = Duration(milliseconds: 300);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

class DebounceCounterBloc extends Bloc<CounterEvent, int> {
  DebounceCounterBloc() : super(0) {
    on<CounterEvent>(_onEvent, transformer: debounce(_debounceDuration));
  }

  void _onEvent(CounterEvent event, Emitter<int> emit) {
    switch (event) {
      case CounterEvent.increment:
        return emit(state + 1);
    }
  }
}
