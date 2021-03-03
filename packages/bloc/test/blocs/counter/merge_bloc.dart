import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../blocs.dart';

class MergeBloc extends Bloc<CounterEvent, int> {
  MergeBloc({this.onTransitionCallback}) : super(0);

  final void Function(Transition<CounterEvent, int>)? onTransitionCallback;

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    super.onTransition(transition);
    onTransitionCallback?.call(transition);
  }

  @override
  Stream<Transition<CounterEvent, int>> transformEvents(
    Stream<CounterEvent> events,
    TransitionFunction<CounterEvent, int> transitionFn,
  ) {
    final nonDebounceStream =
        events.where((event) => event != CounterEvent.increment);

    final debounceStream = events
        .where((event) => event == CounterEvent.increment)
        .throttleTime(const Duration(milliseconds: 100));

    return super.transformEvents(
      MergeStream([nonDebounceStream, debounceStream]),
      transitionFn,
    );
  }

  @override
  Stream<int> mapEventToState(
    CounterEvent event,
  ) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
