import 'dart:async';

import 'package:bloc/bloc.dart';

class ExceptionCounterBlocException implements Exception {}

enum ExceptionCounterEvent { increment }

class ExceptionCounterBloc extends Bloc<ExceptionCounterEvent, int> {
  ExceptionCounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(
    ExceptionCounterEvent event,
  ) async* {
    switch (event) {
      case ExceptionCounterEvent.increment:
        yield state + 1;
        throw ExceptionCounterBlocException();
        break;
    }
  }
}
