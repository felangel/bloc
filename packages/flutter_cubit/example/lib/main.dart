import 'dart:async';

import 'package:cubit/cubit.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:flutter/material.dart';

void main() => runApp(CounterApp());

class CounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: CubitProvider(
        create: (_) => CounterCubit(),
        child: CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: CubitBuilder<CounterCubit, int>(
        builder: (_, count) {
          return Center(
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 24.0),
            ),
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
        ],
      ),
    );
  }
}

class CounterCubit extends Cubit<int> {
  @override
  int get initialState => 0;

  Future<void> increment() => emit(state + 1);
  Future<void> decrement() => emit(state - 1);
}
