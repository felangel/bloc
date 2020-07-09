import 'package:cubit/cubit.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit({this.onTransitionCallback}) : super(0);

  final void Function(Transition<int>) onTransitionCallback;

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);

  @override
  void onTransition(Transition<int> transition) {
    onTransitionCallback?.call(transition);
    super.onTransition(transition);
  }
}
