import 'dart:async';

import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
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
      default:
        throw Exception('unhandled event: $event');
    }
  }
}

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    super.onTransition(transition);
    print(transition);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    super.onError(error, stacktrace);
    print(error);
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

  counterBloc.dispatch(null); // Triggers Exception

  // The exception triggers `SimpleBlocDelegate.onError` but does not impact bloc functionality.
  counterBloc.dispatch(CounterEvent.increment);
  counterBloc.dispatch(CounterEvent.decrement);
}
