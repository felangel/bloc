import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    required this.repository,
    required this.child,
    Key? key,
    this.useValueProvider = false,
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
  const MyStatefulApp({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  State<MyStatefulApp> createState() => _MyStatefulAppState();
}

class _MyStatefulAppState extends State<MyStatefulApp> {
  late Repository _repository;

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
              ),
            ],
          ),
          body: widget.child,
        ),
      ),
    );
  }
}

class MyAppNoProvider extends MaterialApp {
  const MyAppNoProvider({required Widget child, Key? key})
      : super(key: key, home: child);
}

class CounterPage extends StatelessWidget {
  const CounterPage({Key? key, this.onBuild}) : super(key: key);

  final VoidCallback? onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild?.call();
    final repository = RepositoryProvider.of<Repository>(context);

    return Scaffold(
      body: Text('${repository.data}', key: const Key('value_data')),
    );
  }
}

class RoutePage extends StatelessWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        key: const Key('route_button'),
        child: const SizedBox(),
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

      final counterFinder = find.byKey(const Key('value_data'));
      expect(counterFinder, findsOneWidget);

      final counterText = counterFinder.evaluate().first.widget as Text;
      expect(counterText.data, '0');
    });

    testWidgets('passes value to children via value', (tester) async {
      const repository = Repository(0);
      const child = CounterPage();
      await tester.pumpWidget(
        const MyApp(
          repository: repository,
          useValueProvider: true,
          child: child,
        ),
      );

      final counterFinder = find.byKey(const Key('value_data'));
      expect(counterFinder, findsOneWidget);

      final counterText = counterFinder.evaluate().first.widget as Text;
      expect(counterText.data, '0');
    });

    testWidgets(
        'should throw FlutterError if RepositoryProvider is not found in '
        'current context', (tester) async {
      const child = CounterPage();
      await tester.pumpWidget(const MyAppNoProvider(child: child));
      final dynamic exception = tester.takeException();
      const expectedMessage = '''
        RepositoryProvider.of() called with a context that does not contain a repository of type Repository.
        No ancestor could be found starting from the context that was passed to RepositoryProvider.of<Repository>().

        This can happen if the context you used comes from a widget above the RepositoryProvider.

        The context used was: CounterPage(dirty)
''';
      expect((exception as FlutterError).message, expectedMessage);
    });

    testWidgets(
        'should throw StateError if internal '
        'exception is thrown', (tester) async {
      const expected = 'Tried to read a provider that threw '
          'during the creation of its value.\n'
          'The exception occurred during the creation of type Repository.';
      final onError = FlutterError.onError;
      final flutterErrors = <FlutterErrorDetails>[];
      FlutterError.onError = flutterErrors.add;
      await tester.pumpWidget(
        RepositoryProvider<Repository>(
          lazy: false,
          create: (_) => throw Exception('oops'),
          child: const SizedBox(),
        ),
      );
      FlutterError.onError = onError;
      expect(
        flutterErrors,
        contains(
          isA<FlutterErrorDetails>().having(
            (d) => d.exception,
            'exception',
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains(expected),
            ),
          ),
        ),
      );
    });

    testWidgets(
        'should throw StateError '
        'if exception is for different provider', (tester) async {
      const expected = 'Tried to read a provider that threw '
          'during the creation of its value.\n'
          'The exception occurred during the creation of type Repository.';
      final onError = FlutterError.onError;
      final flutterErrors = <FlutterErrorDetails>[];
      FlutterError.onError = flutterErrors.add;
      await tester.pumpWidget(
        RepositoryProvider<Repository>(
          lazy: false,
          create: (context) {
            context.read<int>();
            return const Repository(0);
          },
          child: const SizedBox(),
        ),
      );
      FlutterError.onError = onError;
      expect(
        flutterErrors,
        contains(
          isA<FlutterErrorDetails>().having(
            (d) => d.exception,
            'exception',
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains(expected),
            ),
          ),
        ),
      );
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
        'should rebuild widgets that inherited the value if the value is '
        'changed with context.watch', (tester) async {
      var numBuilds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              var repository = const Repository(0);
              return RepositoryProvider.value(
                value: repository,
                child: StatefulBuilder(
                  builder: (context, _) {
                    numBuilds++;
                    final data = context.watch<Repository>().data;
                    return TextButton(
                      child: Text('Data: $data'),
                      onPressed: () {
                        setState(() => repository = const Repository(1));
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(numBuilds, 2);
    });

    testWidgets(
        'should rebuild widgets that inherited the value if the value is '
        'changed with listen: true', (tester) async {
      var numBuilds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              var repository = const Repository(0);
              return RepositoryProvider.value(
                value: repository,
                child: StatefulBuilder(
                  builder: (context, _) {
                    numBuilds++;
                    final data =
                        RepositoryProvider.of<Repository>(context, listen: true)
                            .data;
                    return TextButton(
                      child: Text('Data: $data'),
                      onPressed: () {
                        setState(() => repository = const Repository(1));
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(numBuilds, 2);
    });

    testWidgets(
        'should access repository instance '
        'via context.read', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider(
          create: (_) => const Repository(0),
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Builder(
                  builder: (context) => Text(
                    '${context.read<Repository>().data}',
                    key: const Key('value_data'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final counterFinder = find.byKey(const Key('value_data'));
      expect(counterFinder, findsOneWidget);

      final counterText = counterFinder.evaluate().first.widget as Text;
      expect(counterText.data, '0');
    });
  });
}
