import 'package:bloc/bloc.dart';

import 'blocs.dart';

class ErrorCounterBlocError extends Error {}

class ErrorCounterBloc extends Bloc<CounterEvent, int> {
  ErrorCounterBloc() : super(0) {
    on<CounterEvent>((event, emit) {
      switch (event) {
        case CounterEvent.increment:
          emit(state + 1);
          throw ErrorCounterBlocError();
      }
    });
  }
}
