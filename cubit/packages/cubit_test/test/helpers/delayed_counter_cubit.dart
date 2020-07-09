import 'package:cubit/cubit.dart';

class DelayedCounterCubit extends Cubit<int> {
  DelayedCounterCubit() : super(0);

  void increment() {
    Future<void>.delayed(
      const Duration(milliseconds: 300),
      () => emit(state + 1),
    );
  }
}
