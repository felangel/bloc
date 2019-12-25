import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'plugins/desktop/desktop.dart';

void main() async {
  // https://github.com/flutter/flutter/pull/38464
  // Changes in Flutter v1.9.4 require you to call WidgetsFlutterBinding.ensureInitialized()
  // before using any plugins if the code is executed before runApp.
  // As a result, you will need the following line if you're using Flutter >=1.9.4.
  WidgetsFlutterBinding.ensureInitialized();
  setTargetPlatformForDesktop();
  BlocSupervisor.delegate = await HydratedBlocDelegate.build();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      create: (context) => CounterBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        home: CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterBloc, CounterState>(
        builder: (BuildContext context, CounterState state) {
          return Center(
            child: Text(
              '${state.value}',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.delete_forever),
              onPressed: () async {
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

class CounterState {
  int value;

  CounterState(this.value);

  @override
  String toString() => 'CounterState { value: $value }';
}

class CounterBloc extends HydratedBloc<CounterEvent, CounterState> {
  @override
  CounterState get initialState => super.initialState ?? CounterState(0);

  @override
  Stream<CounterState> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield CounterState(state.value - 1);
        break;
      case CounterEvent.increment:
        yield CounterState(state.value + 1);
        break;
      case CounterEvent.reset:
        yield CounterState(0);
        break;
    }
  }

  @override
  CounterState fromJson(Map<String, dynamic> source) {
    return CounterState(source['value'] as int);
  }

  @override
  Map<String, int> toJson(CounterState state) {
    return {'value': state.value};
  }
}
