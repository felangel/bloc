import 'package:cubit/cubit.dart';

void main() async {
  final cubit = CounterCubit()
    ..listen(print)
    ..increment();
  await cubit.close();
}

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(initialState: 0);

  void increment() => emit(state + 1);
}
