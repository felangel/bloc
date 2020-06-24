import 'dart:async';

import 'package:bloc/bloc.dart';

enum SideEffectCounterEvent { increment }

class Repository {
  void sideEffect() {}
}

class SideEffectCounterBloc extends Bloc<SideEffectCounterEvent, int> {
  final Repository repository;

  SideEffectCounterBloc(this.repository) : super(0);

  @override
  Stream<int> mapEventToState(
    SideEffectCounterEvent event,
  ) async* {
    switch (event) {
      case SideEffectCounterEvent.increment:
        repository.sideEffect();
        yield state + 1;
        break;
    }
  }
}
