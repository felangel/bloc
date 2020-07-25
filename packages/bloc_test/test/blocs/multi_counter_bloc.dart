import 'dart:async';

import 'package:bloc/bloc.dart';

import 'blocs.dart';

class MultiCounterBloc extends Bloc<CounterEvent, int> {
  MultiCounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        yield state + 1;
        break;
    }
  }
}
