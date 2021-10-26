import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit({this.onChangeCallback, this.onErrorCallback}) : super(0);

  final void Function(Change<int>)? onChangeCallback;
  final void Function(Object error, StackTrace stackTrace)? onErrorCallback;

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);

  @override
  void onChange(Change<int> change) {
    super.onChange(change);
    onChangeCallback?.call(change);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback?.call(error, stackTrace);
    super.onError(error, stackTrace);
  }
}
