import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MyApp extends StatelessWidget {
  final Repository _repository;
  final Widget _child;
  final bool useValueProvider;

  const MyApp({
    Key key,
    @required Repository repository,
    @required Widget child,
    this.useValueProvider,
  })  : _repository = repository,
        _child = child,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useValueProvider == true) {
      return MaterialApp(
        home: RepositoryProvider<Repository>.value(
          value: _repository,
          child: _child,
        ),
      );
    }
    return MaterialApp(
      home: RepositoryProvider<Repository>(
        create: (context) => _repository,
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
  Repository _repository;

  @override
  void initState() {
    _repository = Repository(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RepositoryProvider<Repository>(
        create: (context) => _repository,
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
                    _repository = Repository(0);
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
    final repository = RepositoryProvider.of<Repository>(context);
    assert(repository != null);

    return Scaffold(
      appBar: AppBar(title: Text('Value')),
      body: Center(
        child: Text(
          '${repository.data}',
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

class Repository {
  final int data;

  Repository(this.data);
}

void main() {
  group('RepositoryProvider', () {
    testWidgets('throws if initialized with no repository', (tester) async {
      await tester.pumpWidget(MyApp(
        repository: null,
        child: CounterPage(),
      ));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('throws if initialized with no child', (tester) async {
      await tester.pumpWidget(MyApp(
        repository: Repository(0),
        child: null,
      ));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('lazily loads repositories by default', (tester) async {
      var createCalled = false;
      await tester.pumpWidget(
        RepositoryProvider(
          create: (_) {
            createCalled = true;
            return Repository(0);
          },
          child: Container(),
        ),
      );
      expect(createCalled, isFalse);
    });

    testWidgets('can override lazy loading', (tester) async {
      var createCalled = false;
      await tester.pumpWidget(
        RepositoryProvider(
          create: (_) {
            createCalled = true;
            return Repository(0);
          },
          lazy: false,
          child: Container(),
        ),
      );
      expect(createCalled, isTrue);
    });

    testWidgets('passes value to children via builder', (tester) async {
      final repository = Repository(0);
      final _child = CounterPage();
      await tester.pumpWidget(MyApp(
        repository: repository,
        child: _child,
      ));

      final _counterFinder = find.byKey((Key('value_data')));
      expect(_counterFinder, findsOneWidget);

      final _counterText = _counterFinder.evaluate().first.widget as Text;
      expect(_counterText.data, '0');
    });

    testWidgets('passes value to children via value', (tester) async {
      final repository = Repository(0);
      final _child = CounterPage();
      await tester.pumpWidget(MyApp(
        repository: repository,
        child: _child,
        useValueProvider: true,
      ));

      final _counterFinder = find.byKey((Key('value_data')));
      expect(_counterFinder, findsOneWidget);

      final _counterText = _counterFinder.evaluate().first.widget as Text;
      expect(_counterText.data, '0');
    });

    testWidgets(
        'should throw FlutterError if RepositoryProvider is not found in '
        'current context', (tester) async {
      final Widget _child = CounterPage();
      await tester.pumpWidget(MyAppNoProvider(
        child: _child,
      ));
      final dynamic exception = tester.takeException();
      final expectedMessage = """
        RepositoryProvider.of() called with a context that does not contain a repository of type Repository.
        No ancestor could be found starting from the context that was passed to RepositoryProvider.of<Repository>().

        This can happen if the context you used comes from a widget above the RepositoryProvider.

        The context used was: CounterPage(dirty)
""";
      expect(exception is FlutterError, true);
      expect(exception.message, expectedMessage);
    });

    testWidgets(
        'should not rebuild widgets that inherited the value if the value is '
        'changed', (tester) async {
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
