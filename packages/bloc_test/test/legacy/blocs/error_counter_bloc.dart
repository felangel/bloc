import 'dart:async';

import 'package:bloc/bloc.dart';

import 'blocs.dart';

class ErrorCounterBlocError extends Error {}

class ErrorCounterBloc extends Bloc<CounterEvent, int> {
  ErrorCounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        throw ErrorCounterBlocError();
    }
  }
}
