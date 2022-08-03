import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit({this.onChangeCallback}) : super(0);

  final void Function(Change<int>)? onChangeCallback;

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void emitSameState() => emit(state, allowEmitSameState: true);
  void emitWithoutParameter() => emit(state);

  @override
  void onChange(Change<int> change) {
    super.onChange(change);
    onChangeCallback?.call(change);
  }
}
