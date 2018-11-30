import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  final CounterBloc _bloc;
  final Widget _child;

  const MyApp({Key key, @required CounterBloc bloc, @required Widget child})
      : _bloc = bloc,
        _child = child,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider<CounterBloc>(
        bloc: _bloc,
        child: _child,
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CounterBloc _counterBloc = BlocProvider.of<CounterBloc>(context);
    assert(_counterBloc != null);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterEvent, int>(
        bloc: _counterBloc,
        builder: (BuildContext context, int count) {
          return Center(
            child: Text(
              '$count',
              key: Key('counter_text'),
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
    );
  }
}

abstract class CounterEvent {}

class IncrementCounter extends CounterEvent {}

class DecrementCounter extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  int get initialState => 0;

  void increment() {
    dispatch(IncrementCounter());
  }

  void decrement() {
    dispatch(DecrementCounter());
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterBloc &&
          runtimeType == other.runtimeType &&
          initialState == other.initialState;

  @override
  int get hashCode =>
      initialState.hashCode ^ mapEventToState.hashCode ^ transform.hashCode;
}

class SimpleBloc extends Bloc<dynamic, String> {
  @override
  String get initialState => '';

  @override
  Stream<String> mapEventToState(String state, dynamic event) async* {
    yield 'state';
  }
}

void main() {
  group('BlocProvider', () {
    testWidgets('throws if initialized with no bloc and no child',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        bloc: null,
        child: null,
      ));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('throws if initialized with no bloc',
        (WidgetTester tester) async {
      final CounterPage _child = CounterPage();
      await tester.pumpWidget(MyApp(
        bloc: null,
        child: _child,
      ));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('throws if initialized with no child',
        (WidgetTester tester) async {
      final CounterBloc _bloc = CounterBloc();
      await tester.pumpWidget(MyApp(
        bloc: _bloc,
        child: null,
      ));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('passes bloc to children', (WidgetTester tester) async {
      final CounterBloc _bloc = CounterBloc();
      final CounterPage _child = CounterPage();
      await tester.pumpWidget(MyApp(
        bloc: _bloc,
        child: _child,
      ));

      final Finder _counterFinder = find.byKey((Key('counter_text')));
      expect(_counterFinder, findsOneWidget);

      final Text _counterText = _counterFinder.evaluate().first.widget;
      expect(_counterText.data, '0');
    });
  });
}
