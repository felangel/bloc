import 'dart:async';

import 'package:bloc/bloc.dart';

import 'blocs.dart';

class InstantEmitBloc extends Bloc<CounterEvent, int> {
  InstantEmitBloc() : super(0) {
    on<CounterEvent>(_onEvent);
    scheduleMicrotask(() => add(CounterEvent.increment));
  }

  void _onEvent(CounterEvent event, Emit<int> emit) async {
    switch (event) {
      case CounterEvent.increment:
        return emit(state + 1);
    }
  }
}
