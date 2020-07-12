import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../blocs.dart';

class FlatMapBloc extends Bloc<CounterEvent, int> {
  FlatMapBloc({this.onChangeCallback, this.onTransitionCallback}) : super(0);

  final void Function(Change<int>) onChangeCallback;
  final void Function(Transition<CounterEvent, int>) onTransitionCallback;

  @override
  void onChange(Change<int> change) {
    super.onChange(change);
    onChangeCallback?.call(change);
  }

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
