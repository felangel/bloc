import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MockCubit<S> extends Cubit<S> {
  MockCubit(S state) : super(state);

  @override
  Stream<S> get stream => Stream<S>.empty();
}

class MyApp extends StatelessWidget {
  const MyApp({
    required Widget child,
    Key? key,
    CounterCubit Function(BuildContext context)? create,
    CounterCubit? value,
  })  : _create = create,
        _value = value,
        _child = child,
        super(key: key);

  final CounterCubit Function(BuildContext context)? _create;
  final CounterCubit? _value;
  final Widget _child;

  @override
  Widget build(BuildContext context) {
    if (_value != null) {
      return MaterialApp(
        home: BlocProvider<CounterCubit>.value(
          value: _value!,
          child: _child,
        ),
      );
    }
    return MaterialApp(
      home: BlocProvider<CounterCubit>(
        create: _create!,
        child: _child,
      ),
    );
  }
}

class MyStatefulApp extends StatefulWidget {
  const MyStatefulApp({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  State<MyStatefulApp> createState() => _MyStatefulAppState();
}

class _MyStatefulAppState extends State<MyStatefulApp> {
  late CounterCubit cubit;

  @override
  void initState() {
    cubit = CounterCubit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider<CounterCubit>(
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
              ),
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
  const MyAppNoProvider({
    required Widget home,
    Key? key,
  }) : super(key: key, home: home);
}

class CounterPage extends StatelessWidget {
  const CounterPage({Key? key, this.onBuild}) : super(key: key);

  final void Function()? onBuild;

  @override
  Widget build(BuildContext context) {
    final counterCubit = BlocProvider.of<CounterCubit>(context);

    return Scaffold(
      body: BlocBuilder<CounterCubit, int>(
        bloc: counterCubit,
        builder: (context, count) {
          onBuild?.call();
          return Text('$count', key: const Key('counter_text'));
        },
      ),
    );
  }
}

class RoutePage extends StatelessWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            key: const Key('route_button'),
            child: const SizedBox(),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<Widget>(
                  builder: (context) => const SizedBox(),
                ),
              );
            },
          ),
          ElevatedButton(
            key: const Key('increment_buton'),
            child: const SizedBox(),
            onPressed: () {
              BlocProvider.of<CounterCubit>(context).increment();
            },
          ),
        ],
      ),
    );
  }
}

class CounterCubit extends Cubit<int> {
  CounterCubit({this.onClose}) : super(0);

  final void Function()? onClose;

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

void main() {
  group('BlocProvider', () {
    testWidgets(
        'throws AssertionError '
        'when child is not specified', (tester) async {
      const expected =
          '''BlocProvider<CounterCubit> used outside of MultiBlocProvider must specify a child''';
      await tester.pumpWidget(BlocProvider(create: (_) => CounterCubit()));
      expect(
        tester.takeException(),
        isA<AssertionError>().having((e) => e.message, 'message', expected),
      );
    });

    testWidgets(
        '.value throws AssertionError '
        'when child is not specified', (tester) async {
      const expected =
          '''BlocProvider<CounterCubit> used outside of MultiBlocProvider must specify a child''';
      await tester.pumpWidget(BlocProvider.value(value: CounterCubit()));
      expect(
        tester.takeException(),
        isA<AssertionError>().having((e) => e.message, 'message', expected),
      );
    });

    testWidgets('lazy is true by default', (tester) async {
      final blocProvider = BlocProvider(
        create: (_) => CounterCubit(),
        child: const SizedBox(),
      );
      expect(blocProvider.lazy, isTrue);
    });

    testWidgets('.value lazy is true', (tester) async {
      final blocProvider = BlocProvider.value(
        value: CounterCubit(),
        child: const SizedBox(),
      );
      expect(blocProvider.lazy, isTrue);
    });

    testWidgets('lazily loads cubits by default', (tester) async {
      var createCalled = false;
      await tester.pumpWidget(
        BlocProvider(
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
        BlocProvider(
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
      const key = Key('__text_count__');
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => CounterCubit(),
            child: Builder(
              builder: (context) => Text(
                '${BlocProvider.of<CounterCubit>(context).state}',
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
      await tester.pumpWidget(
        MyApp(
          create: (_) => CounterCubit(),
          child: const CounterPage(),
        ),
      );

      final counterText = tester.widget<Text>(
        find.byKey(const Key('counter_text')),
      );
      expect(counterText.data, '0');
    });

    testWidgets('passes cubit to children within same build', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider(
              create: (context) => CounterCubit(),
              child: BlocBuilder<CounterCubit, int>(
                builder: (context, state) => Text('state: $state'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('state: 0'), findsOneWidget);
    });

    testWidgets(
        'triggers updates in child with context.watch '
        'when provided bloc instance changes,', (tester) async {
      const buttonKey = Key('__button__');
      var cubit = CounterCubit();
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: cubit,
                child: Builder(
                  builder: (context) {
                    final state = context.watch<CounterCubit>().state;
                    return GestureDetector(
                      onTap: () => cubit.increment(),
                      child: Text('state: $state'),
                    );
                  },
                ),
              ),
              floatingActionButton: FloatingActionButton(
                key: buttonKey,
                onPressed: () => setState(() => cubit = CounterCubit()),
              ),
            ),
          ),
        ),
      );
      expect(find.text('state: 0'), findsOneWidget);

      cubit.increment();
      await tester.pump();

      expect(find.text('state: 1'), findsOneWidget);

      await tester.tap(find.byKey(buttonKey));
      await tester.pump();

      expect(find.text('state: 0'), findsOneWidget);
    });

    testWidgets('can access cubit directly within builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider(
              create: (_) => CounterCubit(),
              child: BlocBuilder<CounterCubit, int>(
                builder: (context, state) => Column(
                  children: [
                    Text('state: $state'),
                    ElevatedButton(
                      key: const Key('increment_button'),
                      child: const SizedBox(),
                      onPressed: () {
                        BlocProvider.of<CounterCubit>(context).increment();
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
    });

    testWidgets('does not call close on cubit if it was not loaded (lazily)',
        (tester) async {
      var closeCalled = false;
      await tester.pumpWidget(
        MyApp(
          create: (_) => CounterCubit(onClose: () => closeCalled = true),
          child: const RoutePage(),
        ),
      );

      final routeButtonFinder = find.byKey(const Key('route_button'));
      expect(routeButtonFinder, findsOneWidget);
      expect(closeCalled, false);

      await tester.tap(routeButtonFinder);
      await tester.pumpAndSettle();

      expect(closeCalled, false);
    });

    testWidgets('calls close on cubit automatically when invoked (lazily)',
        (tester) async {
      var closeCalled = false;
      await tester.pumpWidget(
        MyApp(
          create: (_) => CounterCubit(onClose: () => closeCalled = true),
          child: const RoutePage(),
        ),
      );
      final incrementButtonFinder = find.byKey(const Key('increment_buton'));
      expect(incrementButtonFinder, findsOneWidget);
      await tester.tap(incrementButtonFinder);
      final routeButtonFinder = find.byKey(const Key('route_button'));
      expect(routeButtonFinder, findsOneWidget);
      expect(closeCalled, false);

      await tester.tap(routeButtonFinder);
      await tester.pumpAndSettle();

      expect(closeCalled, true);
    });

    testWidgets('does not close when created using value', (tester) async {
      var closeCalled = false;
      final value = CounterCubit(onClose: () => closeCalled = true);
      const child = RoutePage();
      await tester.pumpWidget(MyApp(value: value, child: child));

      final routeButtonFinder = find.byKey(const Key('route_button'));
      expect(routeButtonFinder, findsOneWidget);
      expect(closeCalled, false);

      await tester.tap(routeButtonFinder);
      await tester.pumpAndSettle();

      expect(closeCalled, false);
    });

    testWidgets(
        'should throw FlutterError if BlocProvider is not found in current '
        'context', (tester) async {
      await tester.pumpWidget(const MyAppNoProvider(home: CounterPage()));
      final dynamic exception = tester.takeException();
      const expectedMessage = '''
        BlocProvider.of() called with a context that does not contain a CounterCubit.
        No ancestor could be found starting from the context that was passed to BlocProvider.of<CounterCubit>().

        This can happen if the context you used comes from a widget above the BlocProvider.

        The context used was: CounterPage(dirty)
''';
      expect((exception as FlutterError).message, expectedMessage);
    });

    testWidgets(
        'should throw StateError if internal '
        'exception is thrown', (tester) async {
      const expected = 'Tried to read a provider that threw '
          'during the creation of its value.\n'
          'The exception occurred during the creation of type CounterCubit.';
      final onError = FlutterError.onError;
      final flutterErrors = <FlutterErrorDetails>[];
      FlutterError.onError = flutterErrors.add;
      await tester.pumpWidget(
        BlocProvider<CounterCubit>(
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
          'The exception occurred during the creation of type CounterCubit.';
      final onError = FlutterError.onError;
      final flutterErrors = <FlutterErrorDetails>[];
      FlutterError.onError = flutterErrors.add;
      await tester.pumpWidget(
        BlocProvider<CounterCubit>(
          lazy: false,
          create: (context) {
            context.read<int>();
            return CounterCubit();
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
        'should not rebuild widgets that inherited the cubit if the cubit is '
        'changed', (tester) async {
      var numBuilds = 0;
      final child = CounterPage(onBuild: () => numBuilds++);
      await tester.pumpWidget(
        MyStatefulApp(
          child: child,
        ),
      );
      await tester.tap(find.byKey(const Key('iconButtonKey')));
      await tester.pump();
      expect(numBuilds, 1);
    });

    testWidgets('listen: true registers context as dependent', (tester) async {
      const textKey = Key('__text__');
      const buttonKey = Key('__button__');
      var counterCubitCreateCount = 0;
      var materialBuildCount = 0;
      var textBuildCount = 0;
      await tester.pumpWidget(
        BlocProvider(
          create: (_) {
            counterCubitCreateCount++;
            return CounterCubit();
          },
          child: Builder(
            builder: (context) {
              materialBuildCount++;
              return MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      textBuildCount++;
                      final count = BlocProvider.of<CounterCubit>(
                        context,
                        listen: true,
                      ).state;
                      return Text('$count', key: textKey);
                    },
                  ),
                  floatingActionButton: FloatingActionButton(
                    key: buttonKey,
                    onPressed: () {
                      context.read<CounterCubit>().increment();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
      var text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, '0');
      expect(counterCubitCreateCount, equals(1));
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(1));

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, '1');
      expect(counterCubitCreateCount, equals(1));
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(2));

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, '2');
      expect(counterCubitCreateCount, equals(1));
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(3));
    });

    testWidgets('context.watch registers context as dependent', (tester) async {
      const textKey = Key('__text__');
      const buttonKey = Key('__button__');
      var counterCubitCreateCount = 0;
      var materialBuildCount = 0;
      var textBuildCount = 0;
      await tester.pumpWidget(
        BlocProvider(
          create: (_) {
            counterCubitCreateCount++;
            return CounterCubit();
          },
          child: Builder(
            builder: (context) {
              materialBuildCount++;
              return MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      textBuildCount++;
                      final count = context.watch<CounterCubit>().state;
                      return Text('$count', key: textKey);
                    },
                  ),
                  floatingActionButton: FloatingActionButton(
                    key: buttonKey,
                    onPressed: () {
                      context.read<CounterCubit>().increment();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
      var text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, '0');
      expect(counterCubitCreateCount, equals(1));
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(1));

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, '1');
      expect(counterCubitCreateCount, equals(1));
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(2));

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, '2');
      expect(counterCubitCreateCount, equals(1));
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(3));
    });

    testWidgets('context.select only rebuilds on changes to selected value',
        (tester) async {
      const textKey = Key('__text__');
      const incrementButtonKey = Key('__increment_button__');
      const decrementButtonKey = Key('__decrement_button__');
      var materialBuildCount = 0;
      var textBuildCount = 0;
      await tester.pumpWidget(
        BlocProvider(
          create: (_) => CounterCubit(),
          child: Builder(
            builder: (context) {
              materialBuildCount++;
              return MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      textBuildCount++;
                      final isPositive = context.select(
                        (CounterCubit c) => c.state >= 0,
                      );
                      return Text('$isPositive', key: textKey);
                    },
                  ),
                  floatingActionButton: Column(
                    children: [
                      FloatingActionButton(
                        key: incrementButtonKey,
                        onPressed: () {
                          context.read<CounterCubit>().increment();
                        },
                      ),
                      FloatingActionButton(
                        key: decrementButtonKey,
                        onPressed: () {
                          context.read<CounterCubit>().decrement();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
      var text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, 'true');
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(1));

      await tester.tap(find.byKey(decrementButtonKey));
      await tester.pumpAndSettle();

      text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, 'false');
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(2));

      await tester.tap(find.byKey(decrementButtonKey));
      await tester.pumpAndSettle();

      text = tester.widget<Text>(find.byKey(textKey));
      expect(text.data, 'false');
      expect(materialBuildCount, equals(1));
      expect(textBuildCount, equals(2));
    });

    testWidgets('should not throw if listen returns null subscription',
        (tester) async {
      await tester.pumpWidget(
        BlocProvider(
          lazy: false,
          create: (_) => MockCubit(0),
          child: const SizedBox(),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
