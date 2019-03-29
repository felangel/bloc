import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  final CounterBloc _bloc;
  final Widget _child;

  const MyApp({
    Key key,
    @required CounterBloc bloc,
    @required Widget child,
  })  : _bloc = bloc,
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

class MyStatefulApp extends StatefulWidget {
  final Widget child;

  const MyStatefulApp({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  _MyStatefulAppState createState() => _MyStatefulAppState();
}

class _MyStatefulAppState extends State<MyStatefulApp> {
  CounterBloc bloc;

  @override
  void initState() {
    bloc = CounterBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider<CounterBloc>(
        bloc: bloc,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Counter'),
            actions: <Widget>[
              IconButton(
                key: Key('iconButtonKey'),
                icon: Icon(Icons.edit),
                tooltip: 'Change State',
                onPressed: () {
                  setState(() {
                    bloc = CounterBloc();
                  });
                },
              )
            ],
          ),
          body: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class MyAppNoProvider extends StatelessWidget {
  final Widget _child;

  const MyAppNoProvider({
    Key key,
    @required Widget child,
  })  : _child = child,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _child,
    );
  }
}

class CounterPage extends StatelessWidget {
  final Function onBuild;

  const CounterPage({Key key, this.onBuild}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CounterBloc _counterBloc = BlocProvider.of<CounterBloc>(context);
    assert(_counterBloc != null);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterEvent, int>(
        bloc: _counterBloc,
        builder: (BuildContext context, int count) {
          if (onBuild != null) {
            onBuild();
          }
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

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState + 1;
        break;
      case CounterEvent.increment:
        yield currentState - 1;
        break;
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
  Stream<String> mapEventToState(dynamic event) async* {
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

      final Text _counterText = _counterFinder.evaluate().first.widget as Text;
      expect(_counterText.data, '0');
    });

    testWidgets(
        'should throw FlutterError if BlocProvider is not found in current context',
        (WidgetTester tester) async {
      final Widget _child = CounterPage();
      await tester.pumpWidget(MyAppNoProvider(
        child: _child,
      ));
      final dynamic exception = tester.takeException();
      final expectedMessage = """
        BlocProvider.of() called with a context that does not contain a Bloc of type CounterBloc.
        No ancestor could be found starting from the context that was passed to BlocProvider.of<CounterBloc>().
        This can happen if the context you use comes from a widget above the BlocProvider.
        This can also happen if you used BlocProviderTree and didn\'t explicity provide 
        the BlocProvider types: BlocProvider(bloc: CounterBloc()) instead of BlocProvider<CounterBloc>(bloc: CounterBloc()).
        The context used was: CounterPage(dirty)
        """;
      expect(exception is FlutterError, true);
      expect(exception.message, expectedMessage);
    });

    testWidgets(
        'should not rebuild widgets that inherited the bloc if the bloc is changed',
        (WidgetTester tester) async {
      int numBuilds = 0;
      final Widget _child = CounterPage(
        onBuild: () {
          numBuilds++;
        },
      );
      await tester.pumpWidget(MyStatefulApp(
        child: _child,
      ));
      await tester.tap(find.byKey(Key('iconButtonKey')));
      await tester.pumpAndSettle();
      expect(numBuilds, 1);
    });
  });
}
