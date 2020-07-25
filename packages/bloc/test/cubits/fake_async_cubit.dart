import 'package:bloc/bloc.dart';

class FakeAsyncCounterCubit extends Cubit<int> {
  FakeAsyncCounterCubit() : super(0);

  Future<void> increment() async {
    final nextState = await _increment(state);
    emit(nextState);
  }

  Future<int> _increment(int value) async {
    return value + 1;
  }
}
