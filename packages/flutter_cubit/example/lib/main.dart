import 'package:flutter/material.dart';

import 'package:cubit/cubit.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

void main() => runApp(CubitCounter());

/// A [StatelessWidget] which uses:
/// * [cubit](https://pub.dev/packages/cubit)
/// * [flutter_cubit](https://pub.dev/packages/flutter_cubit)
/// to manage the state of a counter.
class CubitCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CubitProvider(
        create: (_) => CounterCubit(),
        child: CounterPage(),
      ),
    );
  }
}

/// A [StatelessWidget] which demonstrates
/// how to consume and interact with a [CounterCubit].
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cubit Counter')),
      body: CubitBuilder<CounterCubit, int>(
        builder: (_, count) {
          return Center(
            child: Text('$count', style: Theme.of(context).textTheme.headline1),
          );
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
              onPressed: context.cubit<CounterCubit>().increment,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: context.cubit<CounterCubit>().decrement,
            ),
          ),
        ],
      ),
    );
  }
}

/// {@template counter_cubit}
/// A simple [Cubit] which manages an `int` as its state
/// and exposes two public methods to [increment] and [decrement]
/// the value of the state.
/// {@endtemplate}
class CounterCubit extends Cubit<int> {
  /// {@macro counter_cubit}
  CounterCubit() : super(0);

  /// Increments the [Cubit] state by 1.
  void increment() => emit(state + 1);

  /// Decrements the [Cubit] state by 1.
  void decrement() => emit(state - 1);

  @override
  void onTransition(Transition<int> transition) {
    /// Log all state changes (transitions).
    print(transition);
    super.onTransition(transition);
  }
}
