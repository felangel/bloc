import 'package:cubit/cubit.dart';

void main() async {
  final counterCubit = CounterCubit()..listen(print);

  await counterCubit.increment();
  await counterCubit.increment();
  await counterCubit.increment();

  await counterCubit.decrement();
  await counterCubit.decrement();
  await counterCubit.decrement();
}

class CounterCubit extends Cubit<int> {
  @override
  int get initialState => 0;

  Future<void> increment() => emit(state + 1);
  Future<void> decrement() => emit(state - 1);
}
