import 'package:bloc/bloc.dart';

class SeededBloc extends Bloc<String, int> {
  SeededBloc({required this.seed, required this.states}) : super(seed) {
    on<String>((event, emit) {
      states.forEach(emit.call);
    });
  }

  final List<int> states;
  final int seed;
}
