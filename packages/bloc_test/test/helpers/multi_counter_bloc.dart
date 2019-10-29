import 'dart:async';

import 'package:bloc/bloc.dart';

enum MultiCounterEvent { increment }

class MultiCounterBloc extends Bloc<MultiCounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(
    MultiCounterEvent event,
  ) async* {
    final currentState = state;
    switch (event) {
      case MultiCounterEvent.increment:
        yield currentState + 1;
        yield currentState + 2;
        break;
    }
  }
}
