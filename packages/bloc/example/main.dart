import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc/src/linked_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('onCreate -- bloc: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange -- bloc: ${bloc.runtimeType}, change: $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('onTransition -- bloc: ${bloc.runtimeType}, transition: $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError -- bloc: ${bloc.runtimeType}, error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- bloc: ${bloc.runtimeType}');
  }
}

void main() {
  Bloc.observer = SimpleBlocObserver();
  cubitMain();
  linkedStateBlocMain();
  blocMain();
}

void cubitMain() {
  print('----------CUBIT----------');

  /// Create a `CounterCubit` instance.
  final cubit = CounterCubit();

  /// Access the state of the `cubit` via `state`.
  print(cubit.state); // 0

  /// Interact with the `cubit` to trigger `state` changes.
  cubit.increment();

  /// Access the new `state`.
  print(cubit.state); // 1

  /// Close the `cubit` when it is no longer needed.
  cubit.close();
}

Future<void> blocMain() async {
  print('----------BLOC----------');

  /// Create a `CounterBloc` instance.
  final bloc = CounterBloc();

  /// Access the state of the `bloc` via `state`.
  print(bloc.state);

  /// Interact with the `bloc` to trigger `state` changes.
  bloc.add(CounterIncrementPressed());

  /// Wait for next iteration of the event-loop
  /// to ensure event has been processed.
  await Future<void>.delayed(Duration.zero);

  /// Access the new `state`.
  print(bloc.state);

  /// Close the `bloc` when it is no longer needed.
  await bloc.close();
}

void linkedStateBlocMain() {
  print('----------linkedStateBlocMain----------');

  /// Create a `CounterBloc` instance.
  final bloc = LinkedCounterBloc(0, CounterInitEvent());

  /// Access the state of the `bloc` via `state`.
  print(bloc.state.data);

  /// Increment counter twice and decrement it once.
  bloc
    ..increment()
    ..increment()
    ..decrement();

  /// Print the timeline of the events
  print(bloc.timeline());

  /// Go to previous state once
  bloc.pop();

  /// Increment and decrement again to start a new history from this node.
  bloc
    ..increment()
    ..increment()
    ..increment()
    ..decrement()
    ..increment();

  /// Print again the timeline to see the difference.
  print(bloc.timeline());
}

/// A `CounterCubit` which manages an `int` as its state.
class CounterCubit extends Cubit<int> {
  /// The initial state of the `CounterCubit` is 0.
  CounterCubit() : super(0);

  /// When increment is called, the current state
  /// of the cubit is accessed via `state` and
  /// a new `state` is emitted via `emit`.
  void increment() => emit(state + 1);
}

/// The events which `CounterBloc` will react to.
abstract class CounterEvent extends Event {}

/// Initial CounterEvent.
class CounterInitEvent extends CounterEvent {}

/// Notifies bloc to increment state.
class CounterIncrementPressed extends CounterEvent {}

/// Notifies bloc to decrement state.
class CounterDecrementPressed extends CounterEvent {}

/// A `CounterBloc` which handles converting `CounterEvent`s into `int`s.
class CounterBloc extends Bloc<CounterEvent, int> {
  /// The initial state of the `CounterBloc` is 0.
  CounterBloc() : super(0) {
    /// When a `CounterIncrementPressed` event is added,
    /// the current `state` of the bloc is accessed via the `state` property
    /// and a new state is emitted via `emit`.
    on<CounterIncrementPressed>((event, emit) => emit(state + 1));
  }
}

/// A `LinkedCounterBloc` which manages an `int` as its state and `CounterEvent`
/// as its event.
class LinkedCounterBloc extends LinkedStateBloc<int, CounterEvent> {
  LinkedCounterBloc(int data, CounterEvent event) : super(data, event);

  /// This one increment the counter
  void increment() => emit(state.data + 1, CounterIncrementPressed());

  /// And this one decrement the counter
  void decrement() => emit(state.data - 1, CounterIncrementPressed());
}
