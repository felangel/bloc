import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class SeededBloc extends Bloc<String, int> {
  final List<int> states;
  final int seed;

  SeededBloc({@required this.seed, @required this.states}) : super(seed);

  @override
  Stream<int> mapEventToState(String event) async* {
    for (final state in states) {
      yield state;
    }
  }
}
