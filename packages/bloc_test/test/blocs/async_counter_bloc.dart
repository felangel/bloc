import 'dart:async';

import 'package:bloc/bloc.dart';

import 'blocs.dart';

class AsyncCounterBloc extends Bloc<CounterEvent, int> {
  AsyncCounterBloc() : super(0) {
    on<CounterEvent>(_onEvent);
  }

  void _onEvent(CounterEvent event, Emitter<int> emit) async {
    switch (event) {
      case CounterEvent.increment:
        await Future<void>.delayed(const Duration(microseconds: 1));
        return emit(state + 1);
    }
  }
}
