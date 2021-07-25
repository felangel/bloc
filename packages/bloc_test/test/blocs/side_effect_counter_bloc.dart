import 'package:bloc/bloc.dart';

import 'blocs.dart';

class Repository {
  void sideEffect() {}
}

class SideEffectCounterBloc extends Bloc<CounterEvent, int> {
  SideEffectCounterBloc(this.repository) : super(0) {
    on<CounterEvent>(_onEvent);
  }

  final Repository repository;

  void _onEvent(CounterEvent event, Emitter<int> emit) {
    switch (event) {
      case CounterEvent.increment:
        repository.sideEffect();
        return emit(state + 1);
    }
  }
}
