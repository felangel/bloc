import 'package:bloc/bloc.dart';
import 'package:replay_bloc/replay_bloc.dart';

abstract class CounterEvent extends ReplayEvent {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}

class CounterBloc extends ReplayBloc<CounterEvent, int> {
  CounterBloc({
    int? limit,
    this.onEventCallback,
    this.onTransitionCallback,
  }) : super(0, limit: limit);

  final void Function(ReplayEvent)? onEventCallback;
  final void Function(Transition<ReplayEvent, int>)? onTransitionCallback;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    if (event is Increment) {
      yield state + 1;
    } else if (event is Decrement) {
      yield state - 1;
    }
  }

  @override
  void onEvent(ReplayEvent event) {
    onEventCallback?.call(event);
    super.onEvent(event);
  }

  @override
  void onTransition(Transition<ReplayEvent, int> transition) {
    onTransitionCallback?.call(transition);
    super.onTransition(transition);
  }
}

class CounterBlocMixin extends Bloc<CounterEvent, int>
    with ReplayBlocMixin<CounterEvent, int> {
  CounterBlocMixin({int? limit}) : super(0) {
    if (limit != null) {
      this.limit = limit;
    }
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    if (event is Increment) {
      yield state + 1;
    } else if (event is Decrement) {
      yield state - 1;
    }
  }
}
