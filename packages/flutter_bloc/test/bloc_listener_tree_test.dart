import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MyAppNoBlocListenersNoChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListenerTree(
      blocListeners: null,
      child: null,
    );
  }
}

class MyAppNoBlocListeners extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListenerTree(
      blocListeners: null,
      child: Container(),
    );
  }
}

class MyAppNoChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListenerTree(
      blocListeners: [],
      child: null,
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final CounterBloc _counterBloc = CounterBloc();
  final ThemeBloc _themeBloc = ThemeBloc();

  @override
  void dispose() {
    _counterBloc.dispose();
    _themeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocListenerTree(blocListeners: [
        BlocListener<CounterEvent, int>(
          bloc: _counterBloc,
          listener: (BuildContext context, int state) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                key: Key('snackbar_counter'),
                content: Text(state.toString()),
              ),
            );
          },
        ),
        BlocListener<ThemeEvent, ThemeData>(
          bloc: _themeBloc,
          listener: (BuildContext context, ThemeData state) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                key: Key('snackbar_theme'),
                content: Text(state.toString()),
              ),
            );
          },
        )
      ], child: Container()),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                _counterBloc.dispatch(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                _counterBloc.dispatch(CounterEvent.decrement);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.update),
              onPressed: () {
                _themeBloc.dispatch(ThemeEvent.toggle);
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}

enum ThemeEvent { toggle }

class ThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  @override
  ThemeData get initialState => ThemeData.light();

  @override
  Stream<ThemeData> mapEventToState(ThemeEvent event) async* {
    switch (event) {
      case ThemeEvent.toggle:
        yield currentState == ThemeData.dark()
            ? ThemeData.light()
            : ThemeData.dark();
        break;
    }
  }
}

void main() {
  group('BlocListenerTree', () {
    testWidgets('throws if initialized with no blocListeners and no child',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyAppNoBlocListenersNoChild());
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('throws if initialized with no bloc',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyAppNoBlocListeners());
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('throws if initialized with no child',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyAppNoChild());
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('states handled by bloc listeners',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      final Finder _snackbarCounterFinder =
          find.byKey((Key('snackbar_counter')));
      final Finder _snackbarThemeFinder = find.byKey((Key('snackbar_theme')));

      expectLater(_snackbarCounterFinder, findsOneWidget);
      expectLater(_snackbarThemeFinder, findsOneWidget);

      final Text _counterText =
          _snackbarCounterFinder.evaluate().first.widget as Text;
      final Text _themeText =
          _snackbarCounterFinder.evaluate().first.widget as Text;

      expectLater(_counterText.data, '0');

      expectLater(_themeText.data, ThemeData.light().toString());
    });
  });
}
