import 'package:replay_cubit/replay_cubit.dart';

class CounterCubit extends ReplayCubit<int> {
  CounterCubit({int limit}) : super(0, limit: limit);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
