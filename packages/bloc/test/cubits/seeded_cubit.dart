import 'package:bloc/bloc.dart';

class SeededCubit<T> extends Cubit<T> {
  SeededCubit({T initialState}) : super(initialState);

  void emitState(T state) => emit(state);
}
