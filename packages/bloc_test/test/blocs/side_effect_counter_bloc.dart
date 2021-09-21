import 'package:bloc/bloc.dart';

import 'blocs.dart';

class Repository {
  void sideEffect() {}
}

class SideEffectCounterBloc extends Bloc<CounterEvent, int> {
  SideEffectCounterBloc(this.repository) : super(0) {
    on<CounterEvent>((event, emit) {
      switch (event) {
        case CounterEvent.increment:
          repository.sideEffect();
          return emit(state + 1);
      }
    });
  }

  final Repository repository;
}
