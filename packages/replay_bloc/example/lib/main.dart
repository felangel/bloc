import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:replay_bloc/replay_bloc.dart';

void main() {
  Bloc.observer = AppBlocObserver();
  runApp(const App());
}

/// Custom [BlocObserver] that observes all bloc and cubit state changes.
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) print(change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}

/// {@template app}
/// A [StatelessWidget] that:
/// * uses [replay_bloc](https://pub.dev/packages/replay_bloc)
/// and [flutter_bloc](https://pub.dev/packages/flutter_bloc)
/// to manage the state of a counter.
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro app}
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterBloc(),
      child: const MaterialApp(
        home: CounterPage(),
      ),
    );
  }
}

/// {@template counter_page}
/// A [StatelessWidget] that:
/// * demonstrates how to consume and interact with a [ReplayBloc]/[ReplayCubit].
/// {@endtemplate}
class CounterPage extends StatelessWidget {
  /// {@macro counter_page}
  const CounterPage({Key? key}) : super(key: key);
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
      body: Center(
        child: BlocBuilder<CounterBloc, int>(
          builder: (context, state) {
            return Text('$state', style: textTheme.headline2);
          },
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              context.read<CounterBloc>().add(CounterIncrementPressed());
            },
          ),
          const SizedBox(height: 4),
          FloatingActionButton(
            child: const Icon(Icons.remove),
            onPressed: () {
              context.read<CounterBloc>().add(CounterDecrementPressed());
            },
          ),
          const SizedBox(height: 4),
          FloatingActionButton(
            child: const Icon(Icons.delete_forever),
            onPressed: () {
              context.read<CounterBloc>().add(CounterResetPressed());
            },
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
class CounterIncrementPressed extends CounterEvent {
  @override
  String toString() => 'CounterIncrementPressed';
}

/// Notifies [CounterBloc] to decrement its state.
class CounterDecrementPressed extends CounterEvent {
  @override
  String toString() => 'CounterDecrementPressed';
}

/// Notifies [CounterBloc] to reset its state.
class CounterResetPressed extends CounterEvent {
  @override
  String toString() => 'CounterResetPressed';
}

/// {@template replay_counter_bloc}
/// A simple [ReplayBloc] which manages an `int` as its state
/// and reacts to three events:
/// * [CounterIncrementPressed]
/// * [CounterDecrementPressed]
/// * [CounterResetPressed]
/// {@endtemplate}
class CounterBloc extends ReplayBloc<CounterEvent, int> {
  /// {@macro replay_counter_bloc}
  CounterBloc() : super(0) {
    on<CounterIncrementPressed>((event, emit) => emit(state + 1));
    on<CounterDecrementPressed>((event, emit) => emit(state - 1));
    on<CounterResetPressed>((event, emit) => emit(0));
  }
}
