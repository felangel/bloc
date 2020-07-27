import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    Key key,
    @required this.repository,
    @required this.child,
    this.useValueProvider,
  }) : super(key: key);

  final Repository repository;
  final Widget child;
  final bool useValueProvider;

  @override
  Widget build(BuildContext context) {
    if (useValueProvider == true) {
      return MaterialApp(
        home: RepositoryProvider<Repository>.value(
          value: repository,
          child: child,
        ),
      );
    }
    return MaterialApp(
      home: RepositoryProvider<Repository>(
        create: (_) => repository,
        child: child,
      ),
    );
  }
}

class MyStatefulApp extends StatefulWidget {
  const MyStatefulApp({Key key, @required this.child}) : super(key: key);

  final Widget child;

  @override
  _MyStatefulAppState createState() => _MyStatefulAppState();
}

class _MyStatefulAppState extends State<MyStatefulApp> {
  Repository _repository;

  @override
  void initState() {
    _repository = const Repository(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RepositoryProvider<Repository>(
        create: (_) => _repository,
        child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                key: const Key('iconButtonKey'),
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() => _repository = const Repository(0));
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

class MyAppNoProvider extends MaterialApp {
  const MyAppNoProvider({Key key, @required Widget child})
      : super(key: key, home: child);
}

class CounterPage extends StatelessWidget {
  const CounterPage({Key key, this.onBuild}) : super(key: key);

  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild?.call();
    final repository = RepositoryProvider.of<Repository>(context);
    assert(repository != null);

    return Scaffold(
      body: Text('${repository.data}', key: const Key('value_data')),
    );
  }
}

class RoutePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RaisedButton(
        key: const Key('route_button'),
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<Widget>(builder: (context) => const SizedBox()),
          );
        },
      ),
    );
  }
}

class Repository {
  const Repository(this.data);

  final int data;
}

void main() {
  group('RepositoryProvider', () {
    testWidgets('throws if initialized with no repository', (tester) async {
      await tester.pumpWidget(
        const MyApp(repository: null, child: CounterPage()),
      );
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('throws if initialized with no child', (tester) async {
      await tester.pumpWidget(
        const MyApp(repository: Repository(0), child: null),
      );
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('lazily loads repositories by default', (tester) async {
      var createCalled = false;
      await tester.pumpWidget(
        RepositoryProvider(
          create: (_) {
            createCalled = true;
            return const Repository(0);
          },
          child: const SizedBox(),
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
            return const Repository(0);
          },
          lazy: false,
          child: const SizedBox(),
        ),
      );
      expect(createCalled, isTrue);
    });

    testWidgets('passes value to children via builder', (tester) async {
      const repository = Repository(0);
      const child = CounterPage();
      await tester.pumpWidget(
        const MyApp(repository: repository, child: child),
      );

      final _counterFinder = find.byKey((const Key('value_data')));
      expect(_counterFinder, findsOneWidget);

      final _counterText = _counterFinder.evaluate().first.widget as Text;
      expect(_counterText.data, '0');
    });

    testWidgets('passes value to children via value', (tester) async {
      const repository = Repository(0);
      const child = CounterPage();
      await tester.pumpWidget(const MyApp(
        repository: repository,
        child: child,
        useValueProvider: true,
      ));

      final _counterFinder = find.byKey((const Key('value_data')));
      expect(_counterFinder, findsOneWidget);

      final _counterText = _counterFinder.evaluate().first.widget as Text;
      expect(_counterText.data, '0');
    });

    testWidgets(
        'should throw FlutterError if RepositoryProvider is not found in '
        'current context', (tester) async {
      const child = CounterPage();
      await tester.pumpWidget(const MyAppNoProvider(child: child));
      final dynamic exception = tester.takeException();
      final expectedMessage = '''
        RepositoryProvider.of() called with a context that does not contain a repository of type Repository.
        No ancestor could be found starting from the context that was passed to RepositoryProvider.of<Repository>().

        This can happen if the context you used comes from a widget above the RepositoryProvider.

        The context used was: CounterPage(dirty)
''';
      expect(exception is FlutterError, true);
      expect(exception.message, expectedMessage);
    });

    testWidgets(
        'should not throw FlutterError if internal '
        'exception is thrown', (tester) async {
      final expectedException = Exception('oops');
      await tester.pumpWidget(
        RepositoryProvider<Repository>(
          lazy: false,
          create: (_) => throw expectedException,
          child: const SizedBox(),
        ),
      );
      final dynamic exception = tester.takeException();
      expect(exception, expectedException);
    });

    testWidgets(
        'should not rebuild widgets that inherited the value if the value is '
        'changed', (tester) async {
      var numBuilds = 0;
      final child = CounterPage(onBuild: () => numBuilds++);
      await tester.pumpWidget(MyStatefulApp(child: child));
      await tester.tap(find.byKey(const Key('iconButtonKey')));
      await tester.pump();
      expect(numBuilds, 1);
    });

    testWidgets(
        'should access repository instance'
        'via RepositoryProviderExtension', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider(
          create: (_) => const Repository(0),
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Builder(
                  builder: (context) => Text(
                    '${context.repository<Repository>().data}',
                    key: const Key('value_data'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final _counterFinder = find.byKey((const Key('value_data')));
      expect(_counterFinder, findsOneWidget);

      final _counterText = _counterFinder.evaluate().first.widget as Text;
      expect(_counterText.data, '0');
    });
  });
}
