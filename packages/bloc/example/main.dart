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
        addError(Exception('unhandled event: $event'));
    }
  }
}

class SimpleBlocObserver extends BlocObserver {
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
  Bloc.observer = SimpleBlocObserver();

  final counterBloc = CounterBloc();

  counterBloc.add(CounterEvent.increment);
  counterBloc.add(CounterEvent.increment);
  counterBloc.add(CounterEvent.increment);

  counterBloc.add(CounterEvent.decrement);
  counterBloc.add(CounterEvent.decrement);
  counterBloc.add(CounterEvent.decrement);

  counterBloc.add(null); // Triggers Exception

  // The exception triggers `SimpleBlocObserver.onError`
  // but does not impact bloc functionality.
  counterBloc.add(CounterEvent.increment);
  counterBloc.add(CounterEvent.decrement);
}
