import 'package:bloc/bloc.dart';

class SeededCubit<T> extends Cubit<T> {
  SeededCubit({
    required T initialState,
    bool emitFailsWhenClosed = true,
  }) : super(initialState, emitFailsWhenClosed: emitFailsWhenClosed);

  void emitState(T state) => emit(state);
}
