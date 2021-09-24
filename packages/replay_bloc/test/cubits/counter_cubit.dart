import 'package:replay_bloc/replay_bloc.dart';

class CounterCubit extends ReplayCubit<int> {
  CounterCubit({
    int? limit,
    this.shouldReplayCallback,
  }) : super(0, limit: limit);

  final bool Function(int)? shouldReplayCallback;

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);

  @override
  bool shouldReplay(int state) {
    return shouldReplayCallback?.call(state) ?? super.shouldReplay(state);
  }
}

class CounterCubitMixin extends Cubit<int> with ReplayCubitMixin<int> {
  CounterCubitMixin({int? limit}) : super(0) {
    if (limit != null) {
      this.limit = limit;
    }
  }

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
