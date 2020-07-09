import 'package:cubit/cubit.dart';

class MyCubitObserver extends CubitObserver {
  @override
  void onTransition(Cubit cubit, Transition transition) {
    print(transition);
    super.onTransition(cubit, transition);
  }
}

void main() async {
  Cubit.observer = MyCubitObserver();
  final cubit = CounterCubit()..increment();
  await cubit.close();
}

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}
