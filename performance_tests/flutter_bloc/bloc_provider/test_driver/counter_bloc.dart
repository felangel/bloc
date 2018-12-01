import 'package:bloc/bloc.dart';

abstract class CounterEvent {}

class Increment extends CounterEvent {
  @override
  String toString() => 'Increment';
}

class Decrement extends CounterEvent {
  @override
  String toString() => 'Decrement';
}

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(int state, CounterEvent event) async* {
    if (event is Increment) {
      yield state + 1;
    }
    if (event is Decrement) {
      yield state - 1;
    }
  }
}
