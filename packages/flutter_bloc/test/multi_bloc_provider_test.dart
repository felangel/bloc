import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MyAppWithNavigation extends StatelessWidget {
  final Widget child;

  MyAppWithNavigation({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }
}

class HomePage extends StatelessWidget {
  final VoidCallback onCounterBlocClosed;
  final VoidCallback onThemeBlocClosed;
  final CounterBloc counterBlocValue;
  final ThemeBloc themeBlocValue;

  HomePage({
    Key key,
    this.onCounterBlocClosed,
    this.onThemeBlocClosed,
    this.counterBlocValue,
    this.themeBlocValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getProviders() {
      final providers = <BlocProvider>[];
      if (counterBlocValue != null) {
        providers.add(
          BlocProvider<CounterBloc>.value(
            value: counterBlocValue,
          ),
        );
      } else {
        providers.add(
          BlocProvider<CounterBloc>(
            create: (context) => CounterBloc(onClose: onCounterBlocClosed),
          ),
        );
      }

      if (themeBlocValue != null) {
        providers.add(
          BlocProvider<ThemeBloc>.value(
            value: themeBlocValue,
          ),
        );
      } else {
        providers.add(
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(onClose: onThemeBlocClosed),
          ),
        );
      }
      return providers;
    }

    return MultiBlocProvider(
      providers: getProviders(),
      child: Builder(
        builder: (context) {
          return Column(
            children: [
              RaisedButton(
                key: Key('pop_button'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<Container>(
                        builder: (context) => Container()),
                  );
                },
              ),
              RaisedButton(
                key: Key('increment_button'),
                onPressed: () {
                  BlocProvider.of<CounterBloc>(context)
                      .add(CounterEvent.increment);
                },
              ),
              RaisedButton(
                key: Key('toggle_theme_button'),
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
    return BlocBuilder(
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
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        bloc: counterBloc,
        builder: (context, count) {
          return Center(
            child: Text(
              '$count',
              key: Key('counter_text'),
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              key: Key('pop_button'),
              child: Icon(Icons.navigate_next),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  final VoidCallback onClose;

  CounterBloc({this.onClose}) : super(0);

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
  final VoidCallback onClose;

  ThemeBloc({this.onClose}) : super(ThemeData.light());

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

      final counterFinder = find.byKey((Key('counter_text')));
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

      final counterFinder = find.byKey((Key('counter_text')));
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

      final counterFinder = find.byKey((Key('counter_text')));
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

      await tester.tap(find.byKey(Key('increment_button')));
      await tester.pump();
      await tester.tap(find.byKey(Key('pop_button')));
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

      await tester.tap(find.byKey(Key('toggle_theme_button')));
      await tester.pump();
      await tester.tap(find.byKey(Key('pop_button')));
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
      await tester.tap(find.byKey(Key('increment_button')));
      await tester.pump();
      await tester.tap(find.byKey(Key('toggle_theme_button')));
      await tester.pump();
      await tester.tap(find.byKey(Key('pop_button')));
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

      await tester.tap(find.byKey(Key('pop_button')));
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

      await tester.tap(find.byKey(Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterBlocClosed, false);
      expect(themeBlocClosed, false);
    });
  });
}
