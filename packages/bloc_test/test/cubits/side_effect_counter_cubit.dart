import 'package:bloc/bloc.dart';

class Repository {
  void sideEffect() {}
}

class SideEffectCounterCubit extends Cubit<int> {
  SideEffectCounterCubit(this._repository) : super(0);

  final Repository _repository;

  void increment() {
    _repository.sideEffect();
    emit(state + 1);
  }
}
