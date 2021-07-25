import 'package:bloc/bloc.dart';

import 'blocs.dart';

const _debounceDuration = Duration(milliseconds: 300);

class DebounceCounterBloc extends Bloc<CounterEvent, int> {
  DebounceCounterBloc() : super(0) {
    on<CounterEvent>(_onEvent, debounceTime(_debounceDuration));
  }

  void _onEvent(CounterEvent event, Emitter<int> emit) {
    switch (event) {
      case CounterEvent.increment:
        return emit(state + 1);
    }
  }
}
