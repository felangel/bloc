import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:replay_bloc/replay_bloc.dart';
import 'package:example/simple_bloc_observer.dart';

void main() async {
  Bloc.observer = SimpleBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build();
  runApp(App());
}

/// A [StatelessWidget] which uses:
/// * [replay_cubit](https://pub.dev/packages/replay_cubit)
/// * [flutter_cubit](https://pub.dev/packages/flutter_cubit)
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
/// how to consume and interact with a [ReplayCubit].
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.headline2;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          BlocBuilder<CounterBloc, int>(
            builder: (context, state) {
              final cubit = context.bloc<CounterBloc>();
              return IconButton(
                icon: const Icon(Icons.undo),
                onPressed: cubit.canUndo ? cubit.undo : null,
              );
            },
          ),
          BlocBuilder<CounterBloc, int>(
            builder: (context, state) {
              final cubit = context.bloc<CounterBloc>();
              return IconButton(
                icon: const Icon(Icons.redo),
                onPressed: cubit.canRedo ? cubit.redo : null,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CounterBloc, int>(
        builder: (BuildContext context, int state) {
          return Center(child: Text('$state', style: textTheme));
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => context.bloc<CounterBloc>().add(Increment()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: () => context.bloc<CounterBloc>().add(Decrement()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.delete_forever),
              onPressed: () => context.bloc<CounterBloc>()..add(Reset()),
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
class CounterCubit extends HydratedCubit<int> with ReplayCubitMixin<int> {
  /// {@macro replay_counter_cubit}
  CounterCubit() : super(0);

  /// Increments the `cubit` state by 1.
  void increment() => emit(state + 1);

  /// Decrements the `cubit` state by 1.
  void decrement() => emit(state - 1);

  /// Resets the `cubit` state to 0.
  void reset() => emit(0);

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, int> toJson(int state) => {'value': state};
}

/// Base event class for the [CounterBloc].
class CounterEvent extends ReplayEvent {}

/// Notifies [CounterEvent] to increment its state.
class Increment extends CounterEvent {}

/// Notifies [CounterEvent] to decrement its state.
class Decrement extends CounterEvent {}

/// Notifies [CounterEvent] to reset its state.
class Reset extends CounterEvent {}

/// {@template replay_counter_bloc}
/// A simple [ReplayCubit] which manages an `int` as its state
/// and exposes three public methods to `increment`, `decrement`, and
/// `reset` the value of the state.
/// {@endtemplate}
class CounterBloc extends HydratedBloc<ReplayEvent, int>
    with ReplayBlocMixin<CounterEvent, int> {
  /// {@macro replay_counter_cubit}
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    if (event is Reset) {
      yield 0;
    } else if (event is Increment) {
      yield state + 1;
    } else if (event is Decrement) {
      yield state - 1;
    }
  }

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, int> toJson(int state) => {'value': state};
}
