import 'package:bloc/bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../blocs.dart';

EventTransformer<CounterEvent> customTransformer() {
  return (events, mapper) {
    final nonDebounceStream =
        events.where((event) => event != CounterEvent.increment);

    final debounceStream = events
        .where((event) => event == CounterEvent.increment)
        .throttle(const Duration(milliseconds: 100));

    return nonDebounceStream
        .merge(debounceStream)
        .concurrentAsyncExpand(mapper);
  };
}

class MergeBloc extends Bloc<CounterEvent, int> {
  MergeBloc({this.onTransitionCallback}) : super(0) {
    on<CounterEvent>(_onCounterEvent, transformer: customTransformer());
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
