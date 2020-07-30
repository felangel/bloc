import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc/src/bloc/bloc_provider.dart';
import 'package:flutter_bloc/src/cubit/cubit_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class MyAppWithNavigation extends StatelessWidget {
  const MyAppWithNavigation({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    Key key,
    this.onCounterBlocClosed,
    this.onThemeBlocClosed,
    this.counterBlocValue,
    this.themeBlocValue,
  }) : super(key: key);

  final VoidCallback onCounterBlocClosed;
  final VoidCallback onThemeBlocClosed;
  final CounterBloc counterBlocValue;
  final ThemeBloc themeBlocValue;

  @override
  Widget build(BuildContext context) {
    final providers = <CubitProviderSingleChildWidget>[
      if (counterBlocValue != null)
        BlocProvider<CounterBloc>.value(
          value: counterBlocValue,
        )
      else
        BlocProvider<CounterBloc>(
          create: (context) => CounterBloc(onClose: onCounterBlocClosed),
        ),
      if (themeBlocValue != null)
        BlocProvider<ThemeBloc>.value(
          value: themeBlocValue,
        )
      else
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(onClose: onThemeBlocClosed),
        ),
    ];

    return MultiBlocProvider(
      providers: providers,
      child: Builder(
        builder: (context) {
          return Column(
            children: [
              RaisedButton(
                key: const Key('pop_button'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<Container>(
                        builder: (context) => Container()),
                  );
                },
              ),
              RaisedButton(
                key: const Key('increment_button'),
                onPressed: () {
                  BlocProvider.of<CounterBloc>(context)
                      .add(CounterEvent.increment);
                },
              ),
              RaisedButton(
                key: const Key('toggle_theme_button'),
                onPressed: () {
                  BlocProvider.of<ThemeBloc>(context).add(ThemeEvent.toggle);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeData>(
      bloc: BlocProvider.of<ThemeBloc>(context),
      builder: (_, theme) {
        return MaterialApp(
          title: 'Flutter Demo',
          home: CounterPage(),
          theme: theme,
        );
      },
    );
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
      ),
      body: BlocBuilder<CounterBloc, int>(
        bloc: counterBloc,
        builder: (context, count) {
          return Center(
            child: Text(
              '$count',
              key: const Key('counter_text'),
              style: const TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              key: const Key('pop_button'),
              child: Icon(Icons.navigate_next),
              onPressed: Navigator.of(context).pop,
            ),
          ),
        ],
      ),
    );
  }
}

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc({this.onClose}) : super(0);

  final VoidCallback onClose;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

enum ThemeEvent { toggle }

class ThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  ThemeBloc({this.onClose}) : super(ThemeData.light());

  final VoidCallback onClose;

  @override
  Stream<ThemeData> mapEventToState(ThemeEvent event) async* {
    switch (event) {
      case ThemeEvent.toggle:
        yield state == ThemeData.dark() ? ThemeData.light() : ThemeData.dark();
        break;
    }
  }

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

void main() {
  group('MultiBlocProvider', () {
    testWidgets('throws if initialized with no providers', (tester) async {
      try {
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: null,
            child: Container(),
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no child', (tester) async {
      try {
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [],
            child: null,
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('passes blocs to children', (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CounterBloc>(create: (context) => CounterBloc()),
            BlocProvider<ThemeBloc>(create: (context) => ThemeBloc())
          ],
          child: MyApp(),
        ),
      );

      final materialApp =
          tester.widget(find.byType(MaterialApp)) as MaterialApp;
      expect(materialApp.theme, ThemeData.light());

      final counterFinder = find.byKey(const Key('counter_text'));
      expect(counterFinder, findsOneWidget);

      final counterText = tester.widget(counterFinder) as Text;
      expect(counterText.data, '0');
    });

    testWidgets('passes blocs to children without explicit states',
        (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => CounterBloc()),
            BlocProvider(create: (context) => ThemeBloc())
          ],
          child: MyApp(),
        ),
      );

      final materialApp =
          tester.widget(find.byType(MaterialApp)) as MaterialApp;
      expect(materialApp.theme, ThemeData.light());

      final counterFinder = find.byKey(const Key('counter_text'));
      expect(counterFinder, findsOneWidget);

      final counterText = tester.widget(counterFinder) as Text;
      expect(counterText.data, '0');
    });

    testWidgets('adds event to each bloc', (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CounterBloc>(
              create: (context) => CounterBloc()..add(CounterEvent.decrement),
            ),
            BlocProvider<ThemeBloc>(
              create: (context) => ThemeBloc()..add(ThemeEvent.toggle),
            ),
          ],
          child: MyApp(),
        ),
      );

      await tester.pump();

      final materialApp =
          tester.widget(find.byType(MaterialApp)) as MaterialApp;
      expect(materialApp.theme, ThemeData.dark());

      final counterFinder = find.byKey(const Key('counter_text'));
      expect(counterFinder, findsOneWidget);

      final counterText = tester.widget(counterFinder) as Text;
      expect(counterText.data, '-1');
    });

    testWidgets('close on counter bloc which was loaded (lazily)',
        (tester) async {
      var counterBlocClosed = false;
      var themeBlocClosed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterBlocClosed: () {
              counterBlocClosed = true;
            },
            onThemeBlocClosed: () {
              themeBlocClosed = true;
            },
          ),
        ),
      );

      expect(counterBlocClosed, false);
      expect(themeBlocClosed, false);

      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterBlocClosed, true);
      expect(themeBlocClosed, false);
    });

    testWidgets('close on theme bloc which was loaded (lazily)',
        (tester) async {
      var counterBlocClosed = false;
      var themeBlocClosed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterBlocClosed: () {
              counterBlocClosed = true;
            },
            onThemeBlocClosed: () {
              themeBlocClosed = true;
            },
          ),
        ),
      );

      expect(counterBlocClosed, false);
      expect(themeBlocClosed, false);

      await tester.tap(find.byKey(const Key('toggle_theme_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterBlocClosed, false);
      expect(themeBlocClosed, true);
    });

    testWidgets('close on all blocs which were loaded (lazily)',
        (tester) async {
      var counterBlocClosed = false;
      var themeBlocClosed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterBlocClosed: () {
              counterBlocClosed = true;
            },
            onThemeBlocClosed: () {
              themeBlocClosed = true;
            },
          ),
        ),
      );

      expect(counterBlocClosed, false);
      expect(themeBlocClosed, false);
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('toggle_theme_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterBlocClosed, true);
      expect(themeBlocClosed, true);
    });

    testWidgets('does not call close on blocs if they were not loaded (lazily)',
        (tester) async {
      var counterBlocClosed = false;
      var themeBlocClosed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterBlocClosed: () {
              counterBlocClosed = true;
            },
            onThemeBlocClosed: () {
              themeBlocClosed = true;
            },
          ),
        ),
      );

      expect(counterBlocClosed, false);
      expect(themeBlocClosed, false);

      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterBlocClosed, false);
      expect(themeBlocClosed, false);
    });

    testWidgets('does not close when created using value', (tester) async {
      var counterBlocClosed = false;
      var themeBlocClosed = false;

      final counterBloc = CounterBloc(onClose: () {
        counterBlocClosed = true;
      });
      final themeBloc = ThemeBloc(onClose: () {
        themeBlocClosed = true;
      });

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            counterBlocValue: counterBloc,
            themeBlocValue: themeBloc,
          ),
        ),
      );

      expect(counterBlocClosed, false);
      expect(themeBlocClosed, false);

      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterBlocClosed, false);
      expect(themeBlocClosed, false);
    });
  });
}
