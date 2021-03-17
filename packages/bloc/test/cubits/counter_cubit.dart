import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit({this.onTransitionCallback}) : super(0);

  final void Function(Transition<Null, int>)? onTransitionCallback;

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);

  @override
  void onTransition(Transition<Null, int> transition) {
    super.onTransition(transition);
    onTransitionCallback?.call(transition);
  }
}
