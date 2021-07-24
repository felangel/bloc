import 'dart:async';

import 'package:bloc/bloc.dart';

import '../blocs.dart';

class CustomEventModifier extends EventModifier<CounterEvent> {
  @override
  FutureOr<void> call(
    CounterEvent event,
    List<PendingEvent> events,
    void Function() next,
  ) async {
    if (event == CounterEvent.decrement) return next();
    if (events.isEmpty) return next();
    await Future<void>.delayed(const Duration(milliseconds: 100), next);
  }
}

class MergeBloc extends Bloc<CounterEvent, int> {
  MergeBloc({this.onTransitionCallback}) : super(0) {
    on<CounterEvent>(_onCounterEvent, CustomEventModifier());
  }

  final void Function(Transition<CounterEvent, int>)? onTransitionCallback;

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    super.onTransition(transition);
    onTransitionCallback?.call(transition);
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
