import 'package:cubit/cubit.dart';

class FakeAsyncCounterCubit extends Cubit<int> {
  FakeAsyncCounterCubit() : super(0);

  Future<void> increment() async => emit(state + 1);
}
