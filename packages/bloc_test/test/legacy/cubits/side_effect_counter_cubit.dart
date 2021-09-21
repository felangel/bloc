import 'package:bloc/bloc.dart';

class Repository {
  void sideEffect() {}
}

class SideEffectCounterCubit extends Cubit<int> {
  SideEffectCounterCubit(this.repository) : super(0);

  final Repository repository;

  void increment() {
    repository.sideEffect();
    emit(state + 1);
  }
}
