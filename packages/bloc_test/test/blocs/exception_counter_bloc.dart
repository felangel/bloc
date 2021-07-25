import 'package:bloc/bloc.dart';

import 'blocs.dart';

class ExceptionCounterBlocException implements Exception {}

class ExceptionCounterBloc extends Bloc<CounterEvent, int> {
  ExceptionCounterBloc() : super(0) {
    on<CounterEvent>(_onEvent);
  }

  void _onEvent(CounterEvent event, Emitter<int> emit) async {
    switch (event) {
      case CounterEvent.increment:
        emit(state + 1);
        throw ExceptionCounterBlocException();
    }
  }
}
