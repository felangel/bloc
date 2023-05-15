import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class OnTransitionErrorBloc extends Bloc<CounterEvent, int> {
  OnTransitionErrorBloc({
    required this.error,
    required this.onErrorCallback,
  }) : super(0) {
    on<CounterEvent>(_onCounterEvent);
  }

  final void Function(Object, StackTrace) onErrorCallback;
  final Error error;

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback(error, stackTrace);
    super.onError(error, stackTrace);
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    super.onTransition(transition);
    throw error;
  }

  void _onCounterEvent(CounterEvent event, Emitter<int> emit) {
    switch (event) {
      case CounterEvent.increment:
        return emit(state + 1);
      case CounterEvent.decrement:
        return emit(state - 1);
    }
  }
}
