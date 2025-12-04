import 'package:replay_bloc/replay_bloc.dart';

abstract class CounterEvent extends ReplayEvent {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}

class CounterBloc extends ReplayBloc<CounterEvent, int> {
  CounterBloc({
    int? limit,
    void Function(ReplayEvent)? onEventCallback,
    void Function(Transition<ReplayEvent, int>)? onTransitionCallback,
    bool Function(int)? shouldReplayCallback,
  }) : _onEventCallback = onEventCallback,
       _onTransitionCallback = onTransitionCallback,
       _shouldReplayCallback = shouldReplayCallback,
       super(0, limit: limit) {
    on<Increment>((event, emit) => emit(state + 1));
    on<Decrement>((event, emit) => emit(state - 1));
  }

  final void Function(ReplayEvent)? _onEventCallback;
  final void Function(Transition<ReplayEvent, int>)? _onTransitionCallback;
  final bool Function(int)? _shouldReplayCallback;

  @override
  void onEvent(ReplayEvent event) {
    _onEventCallback?.call(event);
    super.onEvent(event);
  }

  @override
  void onTransition(Transition<ReplayEvent, int> transition) {
    _onTransitionCallback?.call(transition);
    super.onTransition(transition);
  }

  @override
  bool shouldReplay(int state) {
    return _shouldReplayCallback?.call(state) ?? super.shouldReplay(state);
  }
}

// ignore: prefer_file_naming_conventions
class CounterBlocMixin extends Bloc<CounterEvent, int>
    with ReplayBlocMixin<CounterEvent, int> {
  CounterBlocMixin({int? limit}) : super(0) {
    if (limit != null) this.limit = limit;
    on<Increment>((event, emit) => emit(state + 1));
    on<Decrement>((event, emit) => emit(state - 1));
  }
}
