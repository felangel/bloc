import 'dart:async';

import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        // Simulating Network Latency
        await Future<void>.delayed(Duration(seconds: 1));
        yield state - 1;
        break;
      case CounterEvent.increment:
        // Simulating Network Latency
        await Future<void>.delayed(Duration(milliseconds: 500));
        yield state + 1;
        break;
      default:
        throw Exception('unhandled event: $event');
    }
  }
}

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    print('bloc: ${bloc.runtimeType}, event: $event');
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print('bloc: ${bloc.runtimeType}, transition: $transition');
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    print('bloc: ${bloc.runtimeType}, error: $error');
    super.onError(bloc, error, stackTrace);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();

  final counterBloc = CounterBloc();

  counterBloc.add(CounterEvent.increment);
  counterBloc.add(CounterEvent.increment);
  counterBloc.add(CounterEvent.increment);

  counterBloc.add(CounterEvent.decrement);
  counterBloc.add(CounterEvent.decrement);
  counterBloc.add(CounterEvent.decrement);

  counterBloc.add(null); // Triggers Exception

  // The exception triggers `SimpleBlocDelegate.onError`
  // but does not impact bloc functionality.
  counterBloc.add(CounterEvent.increment);
  counterBloc.add(CounterEvent.decrement);
}
