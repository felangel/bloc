import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class CounterExceptionBloc extends Bloc<CounterEvent, int> {
  CounterExceptionBloc() : super(0) {
    on<CounterEvent>(_onCounterEvent);
  }

  void _onCounterEvent(CounterEvent event, Emitter<int> emit) {
    switch (event) {
      case CounterEvent.decrement:
        return emit(state - 1);
      case CounterEvent.increment:
        throw Exception('fatal exception');
    }
  }
}
