import 'dart:async';

import 'package:bloc/bloc.dart';

enum AsyncCounterEvent { increment }

class AsyncCounterBloc extends Bloc<AsyncCounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(
    AsyncCounterEvent event,
  ) async* {
    switch (event) {
      case AsyncCounterEvent.increment:
        await Future.delayed(Duration(microseconds: 1));
        yield state + 1;
        break;
    }
  }
}
