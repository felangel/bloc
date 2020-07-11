import 'dart:async';

import 'package:bloc/bloc.dart';

enum MultiCounterEvent { increment }

class MultiCounterBloc extends Bloc<MultiCounterEvent, int> {
  MultiCounterBloc() : super(0);

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
