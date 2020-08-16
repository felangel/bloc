import 'package:bloc/bloc.dart';
import 'package:replay_bloc/replay_bloc.dart';

enum CounterEvent { increment, decrement }

class CounterBloc extends ReplayBloc<CounterEvent, int> {
  CounterBloc({int limit}) : super(0, limit: limit);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
      case CounterEvent.decrement:
        yield state - 1;
        break;
    }
  }
}

class CounterBlocMixin extends Bloc<CounterEvent, int> with ReplayMixin<int> {
  CounterBlocMixin({int limit}) : super(0) {
    this.limit = limit;
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
      case CounterEvent.decrement:
        yield state - 1;
        break;
    }
  }
}
