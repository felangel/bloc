import 'package:bloc/bloc.dart';

class SeededBloc extends Bloc<String, int> {
  SeededBloc({
    required this.seed,
    required this.states,
    this.force = false,
    this.onTransitionCallback,
  }) : super(seed) {
    on<String>((event, emit) {
      for (final state in states) {
        emit(state, force: force);
      }
    });
  }

  final List<int> states;
  final int seed;
  final bool force;
  final void Function(Transition<String, int> transition)? onTransitionCallback;

  @override
  void onTransition(Transition<String, int> transition) {
    super.onTransition(transition);
    onTransitionCallback?.call(transition);
  }
}
