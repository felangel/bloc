import 'package:cubit/cubit.dart';

void main() async {
  final cubit = CounterCubit()..increment();
  await cubit.close();
}

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(initialState: 0);

  void increment() => emit(state + 1);

  @override
  void onTransition(Transition<int> transition) {
    print(transition);
    super.onTransition(transition);
  }
}
