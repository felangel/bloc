import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  final CounterBloc Function(BuildContext context) _create;
  final CounterBloc _value;
  final Widget _child;

  const MyApp({
    Key key,
    CounterBloc Function(BuildContext context) create,
    CounterBloc value,
    @required Widget child,
  })  : _create = create,
        _value = value,
        _child = child,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_value != null) {
      return MaterialApp(
        home: BlocProvider<CounterBloc>.value(
          value: _value,
          child: _child,
        ),
      );
    }
    return MaterialApp(
      home: BlocProvider<CounterBloc>(
        create: _create,
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
        create: (context) => bloc,
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
    bloc.close();
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
    final counterBloc = BlocProvider.of<CounterBloc>(context);
    assert(counterBloc != null);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        bloc: counterBloc,
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
      body: Column(
        children: [
          RaisedButton(
            key: Key('route_button'),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<Widget>(builder: (context) => Container()),
              );
            },
          ),
          RaisedButton(
            key: Key('increment_buton'),
            onPressed: () {
              BlocProvider.of<CounterBloc>(context).add(CounterEvent.increment);
            },
          ),
        ],
      ),
    );
  }
}

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  int get initialState => 0;
  Function onClose;

  CounterBloc({this.onClose});

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
      case CounterEvent.decrement:
        yield state - 1;
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
      initialState.hashCode ^
      mapEventToState.hashCode ^
      transformEvents.hashCode;

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

void main() {
  group('BlocProvider', () {
    testWidgets('throws if initialized with no create',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        create: null,
        child: CounterPage(),
      ));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('throws if initialized with no child',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        create: (context) => CounterBloc(),
        child: null,
      ));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('lazily loads blocs by default', (WidgetTester tester) async {
      var createCalled = false;
      await tester.pumpWidget(
        BlocProvider(
          create: (_) {
            createCalled = true;
            return CounterBloc();
          },
          child: Container(),
        ),
      );
      expect(createCalled, isFalse);
    });

    testWidgets('can override lazy loading', (WidgetTester tester) async {
      var createCalled = false;
      await tester.pumpWidget(
        BlocProvider(
          lazy: false,
          create: (_) {
            createCalled = true;
            return CounterBloc();
          },
          child: Container(),
        ),
      );
      expect(createCalled, isTrue);
    });

    testWidgets('passes bloc to children', (WidgetTester tester) async {
      CounterBloc _create(BuildContext context) => CounterBloc();
      final _child = CounterPage();
      await tester.pumpWidget(MyApp(
        create: _create,
        child: _child,
      ));

      final _counterFinder = find.byKey((Key('counter_text')));
      expect(_counterFinder, findsOneWidget);

      final _counterText = _counterFinder.evaluate().first.widget as Text;
      expect(_counterText.data, '0');
    });

    testWidgets(
      'passes bloc to children within same build',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => CounterBloc(),
                child: BlocBuilder<CounterBloc, int>(
                  builder: (context, state) => Text('state: $state'),
                ),
              ),
            ),
          ),
        );
        expect(find.text('state: 0'), findsOneWidget);
      },
    );

    testWidgets(
      'can access bloc directly within builder',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => CounterBloc(),
                child: BlocBuilder<CounterBloc, int>(
                  builder: (context, state) => Column(
                    children: [
                      Text('state: $state'),
                      RaisedButton(
                        key: Key('increment_button'),
                        onPressed: () {
                          BlocProvider.of<CounterBloc>(context)
                              .add(CounterEvent.increment);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        expect(find.text('state: 0'), findsOneWidget);
        await tester.tap(find.byKey(Key('increment_button')));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('state: 1'), findsOneWidget);
      },
    );

    testWidgets('does not call close on bloc if it was not loaded (lazily)',
        (WidgetTester tester) async {
      var closeCalled = false;
      CounterBloc _create(BuildContext context) => CounterBloc(
            onClose: () {
              closeCalled = true;
            },
          );
      final Widget _child = RoutePage();
      await tester.pumpWidget(MyApp(
        create: _create,
        child: _child,
      ));

      final _routeButtonFinder = find.byKey((Key('route_button')));
      expect(_routeButtonFinder, findsOneWidget);
      expect(closeCalled, false);

      await tester.tap(_routeButtonFinder);
      await tester.pumpAndSettle();

      expect(closeCalled, false);
    });

    testWidgets('calls close on bloc automatically when invoked (lazily)',
        (WidgetTester tester) async {
      var closeCalled = false;
      CounterBloc _create(BuildContext context) => CounterBloc(
            onClose: () {
              closeCalled = true;
            },
          );
      final Widget _child = RoutePage();
      await tester.pumpWidget(MyApp(
        create: _create,
        child: _child,
      ));
      final incrementButtonFinder = find.byKey(Key('increment_buton'));
      expect(incrementButtonFinder, findsOneWidget);
      await tester.tap(incrementButtonFinder);
      final routeButtonFinder = find.byKey((Key('route_button')));
      expect(routeButtonFinder, findsOneWidget);
      expect(closeCalled, false);

      await tester.tap(routeButtonFinder);
      await tester.pumpAndSettle();

      expect(closeCalled, true);
    });

    testWidgets('does not close when created using value',
        (WidgetTester tester) async {
      var closeCalled = false;
      final _value = CounterBloc(
        onClose: () {
          closeCalled = true;
        },
      );
      final Widget _child = RoutePage();
      await tester.pumpWidget(MyApp(
        value: _value,
        child: _child,
      ));

      final _routeButtonFinder = find.byKey((Key('route_button')));
      expect(_routeButtonFinder, findsOneWidget);
      expect(closeCalled, false);

      await tester.tap(_routeButtonFinder);
      await tester.pumpAndSettle();

      expect(closeCalled, false);
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

        This can happen if:
        1. The context you used comes from a widget above the BlocProvider.
        2. You used MultiBlocProvider and didn\'t explicity provide the BlocProvider types.

        Good: BlocProvider<CounterBloc>(create: (context) => CounterBloc())
        Bad: BlocProvider(create: (context) => CounterBloc()).

        The context used was: CounterPage(dirty)
""";
      expect(exception is FlutterError, true);
      expect(exception.message, expectedMessage);
    });

    testWidgets(
        'should not rebuild widgets that inherited the bloc if the bloc is changed',
        (WidgetTester tester) async {
      var numBuilds = 0;
      final Widget _child = CounterPage(
        onBuild: () {
          numBuilds++;
        },
      );
      await tester.pumpWidget(MyStatefulApp(
        child: _child,
      ));
      await tester.tap(find.byKey(Key('iconButtonKey')));
      await tester.pump();
      expect(numBuilds, 1);
    });
  });
}
