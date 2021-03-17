import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:replay_bloc/replay_bloc.dart';
import 'package:example/simple_bloc_observer.dart';

void main() async {
  Bloc.observer = SimpleBlocObserver();
  runApp(App());
}

/// A [StatelessWidget] which uses:
/// * [replay_bloc](https://pub.dev/packages/replay_bloc)
/// * [flutter_bloc](https://pub.dev/packages/flutter_bloc)
/// to manage the state of a counter.
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterBloc(),
      child: MaterialApp(
        home: CounterPage(),
      ),
    );
  }
}

/// A [StatelessWidget] which demonstrates
/// how to consume and interact with a [ReplayBloc] or [ReplayCubit].
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          BlocBuilder<CounterBloc, int>(
            builder: (context, state) {
              final bloc = context.read<CounterBloc>();
              return IconButton(
                icon: const Icon(Icons.undo),
                onPressed: bloc.canUndo ? bloc.undo : null,
              );
            },
          ),
          BlocBuilder<CounterBloc, int>(
            builder: (context, state) {
              final bloc = context.read<CounterBloc>();
              return IconButton(
                icon: const Icon(Icons.redo),
                onPressed: bloc.canRedo ? bloc.redo : null,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CounterBloc, int>(
        builder: (context, state) {
          return Center(child: Text('$state', style: textTheme.headline2));
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => context.read<CounterBloc>().add(Increment()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: () => context.read<CounterBloc>().add(Decrement()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: FloatingActionButton(
              child: const Icon(Icons.delete_forever),
              onPressed: () => context.read<CounterBloc>().add(Reset()),
            ),
          ),
        ],
      ),
    );
  }
}

/// {@template replay_counter_cubit}
/// A simple [ReplayCubit] which manages an `int` as its state
/// and exposes three public methods to `increment`, `decrement`, and
/// `reset` the value of the state.
/// {@endtemplate}
class CounterCubit extends ReplayCubit<int> {
  /// {@macro replay_counter_cubit}
  CounterCubit() : super(0);

  /// Increments the [CounterCubit] state by 1.
  void increment() => emit(state + 1);

  /// Decrements the [CounterCubit] state by 1.
  void decrement() => emit(state - 1);

  /// Resets the [CounterCubit] state to 0.
  void reset() => emit(0);
}

/// Base event class for the [CounterBloc].
class CounterEvent extends ReplayEvent {}

/// Notifies [CounterBloc] to increment its state.
class Increment extends CounterEvent {
  @override
  String toString() => 'Increment';
}

/// Notifies [CounterBloc] to decrement its state.
class Decrement extends CounterEvent {
  @override
  String toString() => 'Decrement';
}

/// Notifies [CounterBloc] to reset its state.
class Reset extends CounterEvent {
  @override
  String toString() => 'Reset';
}

/// {@template replay_counter_bloc}
/// A simple [ReplayBloc] which manages an `int` as its state
/// and reacts to three events: [Increment], [Decrement], and [Reset].
/// {@endtemplate}
class CounterBloc extends ReplayBloc<CounterEvent, int> {
  /// {@macro replay_counter_bloc}
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    if (event is Increment) {
      yield state + 1;
    } else if (event is Decrement) {
      yield state - 1;
    } else if (event is Reset) {
      yield 0;
    }
  }
}
