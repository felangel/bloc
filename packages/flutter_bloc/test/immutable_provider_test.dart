import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  final Value _value;
  final Widget _child;

  const MyApp({
    Key key,
    @required Value value,
    bool dispose,
    @required Widget child,
  })  : _value = value,
        _child = child,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImmutableProvider<Value>(
        value: _value,
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
  Value _value;

  @override
  void initState() {
    _value = Value(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImmutableProvider<Value>(
        value: _value,
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
                    _value = Value(0);
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
    onBuild?.call();
    Value value = ImmutableProvider.of<Value>(context);
    assert(value != null);

    return Scaffold(
      appBar: AppBar(title: Text('Value')),
      body: Center(
        child: Text(
          '${value.data}',
          key: Key('value_data'),
          style: TextStyle(fontSize: 24.0),
        ),
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

class Value {
  final int data;

  Value(this.data);
}

void main() {
  group('ImmutableProvider', () {
    testWidgets('throws if initialized with no value',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        value: null,
        child: CounterPage(),
      ));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('throws if initialized with no child',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        value: Value(0),
        child: null,
      ));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('passes value to children', (WidgetTester tester) async {
      final value = Value(0);
      final CounterPage _child = CounterPage();
      await tester.pumpWidget(MyApp(
        value: value,
        child: _child,
      ));

      final Finder _counterFinder = find.byKey((Key('value_data')));
      expect(_counterFinder, findsOneWidget);

      final Text _counterText = _counterFinder.evaluate().first.widget as Text;
      expect(_counterText.data, '0');
    });

    testWidgets(
        'should throw FlutterError if ImmutableProvider is not found in current context',
        (WidgetTester tester) async {
      final Widget _child = CounterPage();
      await tester.pumpWidget(MyAppNoProvider(
        child: _child,
      ));
      final dynamic exception = tester.takeException();
      final expectedMessage = """
        ImmutableProvider.of() called with a context that does not contain a value of type Value.
        No ancestor could be found starting from the context that was passed to ImmutableProvider.of<Value>().
        This can happen if the context you use comes from a widget above the ImmutableProvider.
        This can also happen if you used ImmutableProviderTree and didn\'t explicity provide 
        the ImmutableProvider types: ImmutableProvider(value: Value()) instead of ImmutableProvider<Value>(value: Value()).
        The context used was: CounterPage(dirty)
        """;
      expect(exception is FlutterError, true);
      expect(exception.message, expectedMessage);
    });

    testWidgets(
        'should not rebuild widgets that inherited the value if the value is changed',
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
