import 'dart:async';

import 'package:bloc/bloc.dart';

import 'blocs.dart';

class InstantEmitBloc extends Bloc<CounterEvent, int> {
  InstantEmitBloc({int seed = 0}) : super(seed) {
    on<CounterEvent>(_onEvent);
    scheduleMicrotask(() => add(CounterEvent.increment));
  }

  void _onEvent(CounterEvent event, Emitter<int> emit) {
    switch (event) {
      case CounterEvent.increment:
        return emit(state + 1);
    }
  }
}
