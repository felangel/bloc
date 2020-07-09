import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() async {
  // https://github.com/flutter/flutter/pull/38464
  // Changes in Flutter v1.9.4 require you to call WidgetsFlutterBinding.ensureInitialized()
  // before using any plugins if the code is executed before runApp.
  // As a result, you will need the following line if you're using Flutter >=1.9.4.
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      create: (_) => CounterBloc(),
      child: MaterialApp(home: CounterPage()),
    );
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        builder: (BuildContext context, int state) {
          return Center(
            child: Text('$state', style: textTheme.headline2),
          );
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
              onPressed: () {
                context.bloc<CounterBloc>().add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: () {
                context.bloc<CounterBloc>().add(CounterEvent.decrement);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.delete_forever),
              onPressed: () async {
                final counterBloc = context.bloc<CounterBloc>();
                await counterBloc.clear();
                counterBloc.add(CounterEvent.reset);
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum CounterEvent { increment, decrement, reset }

class CounterBloc extends HydratedBloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
      case CounterEvent.reset:
        yield 0;
        break;
    }
  }

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, int> toJson(int state) => {'value': state};
}
