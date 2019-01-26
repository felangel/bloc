import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(int currentState, CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        // Simulating Network Latency
        await Future<void>.delayed(Duration(seconds: 1));
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        // Simulating Network Latency
        await Future<void>.delayed(Duration(milliseconds: 500));
        yield currentState + 1;
        break;
    }
  }
}

class SimpleBlocDelegate implements BlocDelegate {
  @override
  void onTransition(Transition transition) {
    print(transition);
  }
}

void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();

  final counterBloc = CounterBloc();

  counterBloc.dispatch(CounterEvent.increment);
  counterBloc.dispatch(CounterEvent.increment);
  counterBloc.dispatch(CounterEvent.increment);

  counterBloc.dispatch(CounterEvent.decrement);
  counterBloc.dispatch(CounterEvent.decrement);
  counterBloc.dispatch(CounterEvent.decrement);
}
