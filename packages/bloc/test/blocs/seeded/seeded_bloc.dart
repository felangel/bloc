import 'package:bloc/bloc.dart';

class SeededBloc extends Bloc<String, int> {
  SeededBloc({required this.seed, required this.states}) : super(seed) {
    on<String>((event, emit) {
      for (final state in states) {
        emit(state);
      }
    });
  }

  final List<int> states;
  final int seed;
}
