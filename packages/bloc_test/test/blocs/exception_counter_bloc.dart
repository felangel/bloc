import 'dart:async';

import 'package:bloc/bloc.dart';

import 'blocs.dart';

class ExceptionCounterBlocException implements Exception {}

class ExceptionCounterBloc extends Bloc<CounterEvent, int> {
  ExceptionCounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        throw ExceptionCounterBlocException();
        break;
    }
  }
}
