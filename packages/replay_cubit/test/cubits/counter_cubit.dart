import 'package:cubit/cubit.dart';
import 'package:replay_cubit/replay_cubit.dart';

class CounterCubit extends ReplayCubit<int> {
  CounterCubit({int limit}) : super(0, limit: limit);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

class CounterCubitMixin extends Cubit<int> with ReplayMixin<int> {
  CounterCubitMixin({int limit}) : super(0) {
    this.limit = limit;
  }

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
