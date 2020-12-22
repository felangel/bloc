import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../blocs.dart';

class FlatMapBloc extends Bloc<CounterEvent, int> {
  FlatMapBloc({this.onTransitionCallback}) : super(0);

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
    return events.flatMap(transitionFn);
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
