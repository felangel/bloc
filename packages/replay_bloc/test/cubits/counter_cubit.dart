import 'package:replay_bloc/replay_bloc.dart';

class CounterCubit extends ReplayCubit<int> {
  CounterCubit({int? limit, bool Function(int)? shouldReplayCallback})
    : _shouldReplayCallback = shouldReplayCallback,
      super(0, limit: limit);

  final bool Function(int)? _shouldReplayCallback;

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);

  @override
  bool shouldReplay(int state) {
    return _shouldReplayCallback?.call(state) ?? super.shouldReplay(state);
  }
}

// ignore: prefer_file_naming_conventions
class CounterCubitMixin extends Cubit<int> with ReplayCubitMixin<int> {
  CounterCubitMixin({int? limit}) : super(0) {
    if (limit != null) {
      this.limit = limit;
    }
  }

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
