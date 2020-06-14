import 'dart:async';

import 'package:cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    Key key,
    CounterCubit Function(BuildContext context) create,
    CounterCubit value,
    @required Widget child,
  })  : _create = create,
        _value = value,
        _child = child,
        super(key: key);

  final CounterCubit Function(BuildContext context) _create;
  final CounterCubit _value;
  final Widget _child;

  @override
  Widget build(BuildContext context) {
    if (_value != null) {
      return MaterialApp(
        home: CubitProvider<CounterCubit>.value(
          value: _value,
          child: _child,
        ),
      );
    }
    return MaterialApp(
      home: CubitProvider<CounterCubit>(
        create: _create,
        child: _child,
      ),
    );
  }
}

class MyStatefulApp extends StatefulWidget {
  const MyStatefulApp({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _MyStatefulAppState createState() => _MyStatefulAppState();
}

class _MyStatefulAppState extends State<MyStatefulApp> {
  CounterCubit cubit;

  @override
  void initState() {
    cubit = CounterCubit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CubitProvider<CounterCubit>(
        create: (context) => cubit,
        child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                key: const Key('iconButtonKey'),
                icon: const Icon(Icons.edit),
                tooltip: 'Change State',
                onPressed: () {
                  setState(() => cubit = CounterCubit());
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
    cubit.close();
    super.dispose();
  }
}

class MyAppNoProvider extends MaterialApp {
  const MyAppNoProvider({Key key, Widget home}) : super(key: key, home: home);
}

class CounterPage extends StatelessWidget {
  const CounterPage({Key key, this.onBuild}) : super(key: key);

  final Function onBuild;

  @override
  Widget build(BuildContext context) {
    final counterCubit = CubitProvider.of<CounterCubit>(context);
    assert(counterCubit != null);

    return Scaffold(
      body: CubitBuilder<CounterCubit, int>(
        cubit: counterCubit,
        builder: (context, count) {
          if (onBuild != null) {
            onBuild();
          }
          return Text('$count', key: const Key('counter_text'));
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
            key: const Key('route_button'),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<Widget>(
                  builder: (context) => const SizedBox(),
                ),
              );
            },
          ),
          RaisedButton(
            key: const Key('increment_buton'),
            onPressed: () {
              CubitProvider.of<CounterCubit>(context).increment();
            },
          ),
        ],
      ),
    );
  }
}

class CounterCubit extends Cubit<int> {
  CounterCubit({this.onClose}) : super(0);

  final Function onClose;

  void increment() => emit(state + 1);

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

void main() {
  group('CubitProvider', () {
    testWidgets('throws if initialized with no create', (tester) async {
      await tester.pumpWidget(const MyApp(create: null, child: CounterPage()));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('throws if initialized with no child', (tester) async {
      await tester.pumpWidget(MyApp(
        create: (context) => CounterCubit(),
        child: null,
      ));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('lazily loads cubits by default', (tester) async {
      var createCalled = false;
      await tester.pumpWidget(
        CubitProvider(
          create: (_) {
            createCalled = true;
            return CounterCubit();
          },
          child: const SizedBox(),
        ),
      );
      expect(createCalled, isFalse);
    });

    testWidgets('lazily loads cubits by default', (tester) async {
      var createCalled = false;
      await tester.pumpWidget(
        CubitProvider(
          create: (_) {
            createCalled = true;
            return CounterCubit();
          },
          child: const SizedBox(),
        ),
      );
      expect(createCalled, isFalse);
    });

    testWidgets('can override lazy loading', (tester) async {
      var createCalled = false;
      await tester.pumpWidget(
        CubitProvider(
          lazy: false,
          create: (_) {
            createCalled = true;
            return CounterCubit();
          },
          child: const SizedBox(),
        ),
      );
      expect(createCalled, isTrue);
    });

    testWidgets('can be provided without an explicit type', (tester) async {
      final key = const Key('__text_count__');
      await tester.pumpWidget(
        MaterialApp(
          home: CubitProvider(
            create: (_) => CounterCubit(),
            child: Builder(
              builder: (context) => Text(
                '${CubitProvider.of<CounterCubit>(context).state}',
                key: key,
              ),
            ),
          ),
        ),
      );
      final text = tester.widget(find.byKey(key)) as Text;
      expect(text.data, '0');
    });

    testWidgets('passes cubit to children', (tester) async {
      await tester.pumpWidget(MyApp(
        create: (_) => CounterCubit(),
        child: const CounterPage(),
      ));

      final _counterFinder = find.byKey((const Key('counter_text')));
      expect(_counterFinder, findsOneWidget);

      final _counterText = _counterFinder.evaluate().first.widget as Text;
      expect(_counterText.data, '0');
    });

    testWidgets(
      'passes cubit to children within same build',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CubitProvider(
                create: (context) => CounterCubit(),
                child: CubitBuilder<CounterCubit, int>(
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
      'can access cubit directly within builder',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CubitProvider(
                create: (_) => CounterCubit(),
                child: CubitBuilder<CounterCubit, int>(
                  builder: (context, state) => Column(
                    children: [
                      Text('state: $state'),
                      RaisedButton(
                        key: const Key('increment_button'),
                        onPressed: () {
                          context.cubit<CounterCubit>().increment();
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
        await tester.tap(find.byKey(const Key('increment_button')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('state: 1'), findsOneWidget);
      },
    );

    testWidgets('does not call close on cubit if it was not loaded (lazily)',
        (tester) async {
      var closeCalled = false;
      await tester.pumpWidget(MyApp(
        create: (_) => CounterCubit(onClose: () => closeCalled = true),
        child: RoutePage(),
      ));

      final _routeButtonFinder = find.byKey((const Key('route_button')));
      expect(_routeButtonFinder, findsOneWidget);
      expect(closeCalled, false);

      await tester.tap(_routeButtonFinder);
      await tester.pumpAndSettle();

      expect(closeCalled, false);
    });

    testWidgets('calls close on cubit automatically when invoked (lazily)',
        (tester) async {
      var closeCalled = false;
      await tester.pumpWidget(MyApp(
        create: (_) => CounterCubit(onClose: () => closeCalled = true),
        child: RoutePage(),
      ));
      final incrementButtonFinder = find.byKey(const Key('increment_buton'));
      expect(incrementButtonFinder, findsOneWidget);
      await tester.tap(incrementButtonFinder);
      final routeButtonFinder = find.byKey((const Key('route_button')));
      expect(routeButtonFinder, findsOneWidget);
      expect(closeCalled, false);

      await tester.tap(routeButtonFinder);
      await tester.pumpAndSettle();

      expect(closeCalled, true);
    });

    testWidgets('does not close when created using value', (tester) async {
      var closeCalled = false;
      final value = CounterCubit(onClose: () => closeCalled = true);
      final Widget _child = RoutePage();
      await tester.pumpWidget(MyApp(value: value, child: _child));

      final _routeButtonFinder = find.byKey((const Key('route_button')));
      expect(_routeButtonFinder, findsOneWidget);
      expect(closeCalled, false);

      await tester.tap(_routeButtonFinder);
      await tester.pumpAndSettle();

      expect(closeCalled, false);
    });

    testWidgets(
        'should throw FlutterError if CubitProvider is not found in current '
        'context', (tester) async {
      await tester.pumpWidget(const MyAppNoProvider(home: CounterPage()));
      final dynamic exception = tester.takeException();
      final expectedMessage = '''
        CubitProvider.of() called with a context that does not contain a Cubit of type CounterCubit.
        No ancestor could be found starting from the context that was passed to CubitProvider.of<CounterCubit>().

        This can happen if the context you used comes from a widget above the CubitProvider.

        The context used was: CounterPage(dirty)
''';
      expect(exception is FlutterError, true);
      expect(exception.message, expectedMessage);
    });

    testWidgets(
        'should not wrap into FlutterError if '
        'ProviderNotFoundException with wrong valueType '
        'is thrown', (tester) async {
      await tester.pumpWidget(
        CubitProvider<CounterCubit>(
          create: (context) => CounterCubit(onClose: Provider.of(context)),
          child: const CounterPage(),
        ),
      );
      final dynamic exception = tester.takeException();
      expect(exception is ProviderNotFoundException, true);
    });

    testWidgets(
        'should not throw FlutterError if internal '
        'exception is thrown', (tester) async {
      final expectedException = Exception('oops');
      await tester.pumpWidget(
        CubitProvider<CounterCubit>(
          lazy: false,
          create: (_) => throw expectedException,
          child: Container(),
        ),
      );
      final dynamic exception = tester.takeException();
      expect(exception, expectedException);
    });

    testWidgets(
        'should not rebuild widgets that inherited the cubit if the cubit is '
        'changed', (tester) async {
      var numBuilds = 0;
      final Widget _child = CounterPage(onBuild: () => numBuilds++);
      await tester.pumpWidget(MyStatefulApp(
        child: _child,
      ));
      await tester.tap(find.byKey(const Key('iconButtonKey')));
      await tester.pump();
      expect(numBuilds, 1);
    });

    testWidgets(
        'should access cubit instance'
        'via CubitProviderExtension', (tester) async {
      await tester.pumpWidget(
        CubitProvider(
          create: (_) => CounterCubit(),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Text(
                  '${context.cubit<CounterCubit>().state}',
                  key: const Key('value_data'),
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
