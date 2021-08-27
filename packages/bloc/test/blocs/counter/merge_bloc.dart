import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../blocs.dart';

EventTransformer<CounterEvent> customTransform() {
  return (Stream<CounterEvent> events, EventMapper<CounterEvent> mapper) {
    final nonDebounceStream =
        events.where((event) => event != CounterEvent.increment);

    final debounceStream = events
        .where((event) => event == CounterEvent.increment)
        .throttleTime(const Duration(milliseconds: 100));

    return Rx.merge([nonDebounceStream, debounceStream]).asyncExpand(mapper);
  };
}

class MergeBloc extends Bloc<CounterEvent, int> {
  MergeBloc({this.onTransitionCallback}) : super(0) {
    on<CounterEvent>(_onCounterEvent, transform: customTransform());
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
