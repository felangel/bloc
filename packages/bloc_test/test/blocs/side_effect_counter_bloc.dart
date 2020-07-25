import 'dart:async';

import 'package:bloc/bloc.dart';

import 'blocs.dart';

class Repository {
  void sideEffect() {}
}

class SideEffectCounterBloc extends Bloc<CounterEvent, int> {
  SideEffectCounterBloc(this.repository) : super(0);

  final Repository repository;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        repository.sideEffect();
        yield state + 1;
        break;
    }
  }
}
