import 'dart:async';

import 'package:bloc/bloc.dart';

import 'blocs.dart';

class AsyncCounterBloc extends Bloc<CounterEvent, int> {
  AsyncCounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        await Future<void>.delayed(const Duration(microseconds: 1));
        yield state + 1;
        break;
    }
  }
}
