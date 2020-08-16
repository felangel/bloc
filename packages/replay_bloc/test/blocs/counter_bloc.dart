import 'package:bloc/bloc.dart';
import 'package:replay_bloc/replay_bloc.dart';

abstract class CounterEvent with ReplayEvent {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}

class CounterBloc extends ReplayBloc<CounterEvent, int> {
  CounterBloc({int limit}) : super(0, limit: limit);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    if (event is Increment) {
      yield state + 1;
    } else if (event is Decrement) {
      yield state - 1;
    }
  }
}

class CounterBlocMixin extends Bloc<ReplayEvent, int>
    with ReplayBlocMixin<CounterEvent, int> {
  CounterBlocMixin({int limit}) : super(0) {
    this.limit = limit;
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    if (event is Increment) {
      yield state + 1;
    } else if (event is Decrement) {
      yield state - 1;
    }
  }
}
