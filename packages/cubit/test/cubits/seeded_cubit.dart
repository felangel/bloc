import 'package:cubit/cubit.dart';

class SeededCubit<T> extends Cubit<T> {
  SeededCubit({T initialState}) : super(initialState: initialState);

  void emitState(T state) => emit(state);
}
