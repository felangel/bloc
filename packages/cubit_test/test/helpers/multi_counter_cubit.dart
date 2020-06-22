import 'package:cubit/cubit.dart';

class MultiCounterCubit extends Cubit<int> {
  MultiCounterCubit() : super(0);

  void increment() {
    emit(state + 1);
    emit(state + 1);
  }
}
