import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final CounterBloc _counterBloc = CounterBloc();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider<CounterBloc>(
        bloc: _counterBloc,
        child: CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc _counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterEvent, int>(
        bloc: _counterBloc,
        builder: (BuildContext context, int count) {
          return Center(
            child: Text(
              '$count',
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
              onPressed: _counterBloc.increment,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: _counterBloc.decrement,
            ),
          ),
        ],
      ),
    );
  }
}

abstract class CounterEvent {}

class IncrementCounter extends CounterEvent {
  @override
  String toString() => 'IncrementCounter';
}

class DecrementCounter extends CounterEvent {
  @override
  String toString() => 'DecrementCounter';
}

class CounterBloc extends Bloc<CounterEvent, int> {
  void increment() {
    dispatch(IncrementCounter());
  }

  void decrement() {
    dispatch(DecrementCounter());
  }

  @override
  int get initialState => 0;

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    print(transition.toString());
  }

  @override
  Stream<int> mapEventToState(int state, CounterEvent event) async* {
    if (event is IncrementCounter) {
      yield state + 1;
    }
    if (event is DecrementCounter) {
      yield state - 1;
    }
  }
}
