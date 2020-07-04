import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:replay_bloc/replay_bloc.dart';

void main() => runApp(App());

/// A [StatelessWidget] which uses:
/// * [replay_bloc](https://pub.dev/packages/replay_bloc)
/// * [flutter_bloc](https://pub.dev/packages/flutter_bloc)
/// to manage the state of a counter.
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      create: (_) => CounterBloc(),
      child: MaterialApp(
        home: CounterPage(),
      ),
    );
  }
}

/// A [StatelessWidget] which demonstrates
/// how to consume and interact with a [ReplayBloc].
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
              final bloc = context.bloc<CounterBloc>();
              return IconButton(
                icon: const Icon(Icons.undo),
                onPressed: bloc.canUndo ? bloc.undo : null,
              );
            },
          ),
          BlocBuilder<CounterBloc, int>(
            builder: (context, state) {
              final bloc = context.bloc<CounterBloc>();
              return IconButton(
                icon: const Icon(Icons.redo),
                onPressed: bloc.canRedo ? bloc.redo : null,
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
                onPressed: () =>
                    context.bloc<CounterBloc>().add(CounterEvent.increment)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: () =>
                  context.bloc<CounterBloc>().add(CounterEvent.decrement),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.delete_forever),
              onPressed: () => context.bloc<CounterBloc>()
                ..add(CounterEvent.reset)
                ..clearHistory(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Supported [CounterBloc] events
enum CounterEvent {
  /// requests an increment
  increment,

  /// requests an decrement
  decrement,

  /// requests an reset
  reset
}

/// {@template replay_counter_bloc}
/// A simple [ReplayBloc] which manages an `int` as its state
/// and exposes three public methods to `increment`, `decrement`, and
/// `reset` the value of the state.
/// {@endtemplate}
class CounterBloc extends ReplayBloc<CounterEvent, int> {
  /// {@macro replay_counter_bloc}
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.reset:
        yield 0;
        break;
    }
  }
}
