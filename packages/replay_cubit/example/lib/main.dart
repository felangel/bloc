import 'package:flutter/material.dart';

import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:hydrated_cubit/hydrated_cubit.dart';
import 'package:replay_cubit/replay_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedCubit.storage = await HydratedStorage.build();
  runApp(App());
}

/// A [StatelessWidget] which uses:
/// * [replay_cubit](https://pub.dev/packages/replay_cubit)
/// * [flutter_cubit](https://pub.dev/packages/flutter_cubit)
/// to manage the state of a counter.
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CubitProvider<CounterCubit>(
      create: (_) => CounterCubit(),
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
          CubitBuilder<CounterCubit, int>(
            builder: (context, state) {
              final cubit = context.cubit<CounterCubit>();
              return IconButton(
                icon: const Icon(Icons.undo),
                onPressed: cubit.canUndo ? cubit.undo : null,
              );
            },
          ),
          CubitBuilder<CounterCubit, int>(
            builder: (context, state) {
              final cubit = context.cubit<CounterCubit>();
              return IconButton(
                icon: const Icon(Icons.redo),
                onPressed: cubit.canRedo ? cubit.redo : null,
              );
            },
          ),
        ],
      ),
      body: CubitBuilder<CounterCubit, int>(
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
              onPressed: () => context.cubit<CounterCubit>().increment(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: () => context.cubit<CounterCubit>().decrement(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.delete_forever),
              onPressed: () => context.cubit<CounterCubit>()
                ..reset()
                ..clear()
                ..clearHistory(),
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
class CounterCubit extends HydratedCubit<int> with ReplayMixin<int> {
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
