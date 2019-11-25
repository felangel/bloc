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
    switch (event) {
      case MultiCounterEvent.increment:
        yield state + 1;
        yield state + 1;
        break;
    }
  }
}
