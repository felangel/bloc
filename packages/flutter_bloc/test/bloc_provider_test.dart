import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  final CounterBloc Function(BuildContext context) _builder;
  final bool _dispose;
  final Widget _child;

  const MyApp({
    Key key,
    @required CounterBloc Function(BuildContext context) builder,
    bool dispose,
    @required Widget child,
  })  : _builder = builder,
        _dispose = dispose,
        _child = child,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider<CounterBloc>(
        builder: _builder,
        dispose: _dispose,
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
        builder: (context) => bloc,
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

class RoutePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RaisedButton(
        key: Key('route_button'),
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<Widget>(builder: (context) => Container()),
          );
        },
      ),
    );
  }
}

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  int get initialState => 0;
  Function onDispose;

  CounterBloc({this.onDispose});

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

  @override
  void dispose() {
    onDispose?.call();
    super.dispose();
  }
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
    testWidgets('throws if initialized with no builder',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        builder: null,
        child: CounterPage(),
      ));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('throws if initialized with no child',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        builder: (context) => CounterBloc(),
        child: null,
      ));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('throws FlutterError if initialized with invalid builder',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        builder: (context) => null,
        child: CounterPage(),
      ));
      final dynamic exception = tester.takeException();
      final String message =
          'BlocProvider\'s builder method did not return a Bloc.';
      expect(exception, isInstanceOf<FlutterError>());
      expect((exception as FlutterError).message, message);
    });

    testWidgets('passes bloc to children', (WidgetTester tester) async {
      final _builder = (BuildContext context) => CounterBloc();
      final CounterPage _child = CounterPage();
      await tester.pumpWidget(MyApp(
        builder: _builder,
        child: _child,
      ));

      final Finder _counterFinder = find.byKey((Key('counter_text')));
      expect(_counterFinder, findsOneWidget);

      final Text _counterText = _counterFinder.evaluate().first.widget as Text;
      expect(_counterText.data, '0');
    });

    testWidgets('calls dispose on bloc automatically',
        (WidgetTester tester) async {
      bool disposeCalled = false;
      final _builder = (BuildContext context) => CounterBloc(
            onDispose: () {
              disposeCalled = true;
            },
          );
      final Widget _child = RoutePage();
      await tester.pumpWidget(MyApp(
        builder: _builder,
        child: _child,
      ));

      final Finder _routeButtonFinder = find.byKey((Key('route_button')));
      expect(_routeButtonFinder, findsOneWidget);
      expect(disposeCalled, false);

      await tester.tap(_routeButtonFinder);
      await tester.pumpAndSettle();

      expect(disposeCalled, true);
    });

    testWidgets('calls dispose on bloc when dispose = true',
        (WidgetTester tester) async {
      bool disposeCalled = false;
      final _builder = (BuildContext context) => CounterBloc(
            onDispose: () {
              disposeCalled = true;
            },
          );
      final Widget _child = RoutePage();
      await tester.pumpWidget(MyApp(
        builder: _builder,
        dispose: true,
        child: _child,
      ));

      final Finder _routeButtonFinder = find.byKey((Key('route_button')));
      expect(_routeButtonFinder, findsOneWidget);
      expect(disposeCalled, false);

      await tester.tap(_routeButtonFinder);
      await tester.pumpAndSettle();

      expect(disposeCalled, true);
    });

    testWidgets('does not dispose when dispose = false',
        (WidgetTester tester) async {
      bool disposeCalled = false;
      final _builder = (BuildContext context) => CounterBloc(
            onDispose: () {
              disposeCalled = true;
            },
          );
      final Widget _child = RoutePage();
      await tester.pumpWidget(MyApp(
        builder: _builder,
        dispose: false,
        child: _child,
      ));

      final Finder _routeButtonFinder = find.byKey((Key('route_button')));
      expect(_routeButtonFinder, findsOneWidget);
      expect(disposeCalled, false);

      await tester.tap(_routeButtonFinder);
      await tester.pumpAndSettle();

      expect(disposeCalled, false);
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
