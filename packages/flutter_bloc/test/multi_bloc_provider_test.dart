import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';

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
  final VoidCallback onCounterBlocDisposed;
  final VoidCallback onThemeBlocDisposed;
  final CounterBloc counterBlocValue;
  final ThemeBloc themeBlocValue;

  HomePage({
    Key key,
    this.onCounterBlocDisposed,
    this.onThemeBlocDisposed,
    this.counterBlocValue,
    this.themeBlocValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getProviders() {
      final List<BlocProvider> providers = List<BlocProvider>();
      if (counterBlocValue != null) {
        providers.add(
          BlocProvider<CounterBloc>.value(
            value: counterBlocValue,
          ),
        );
      } else {
        providers.add(
          BlocProvider<CounterBloc>(
            builder: (context) => CounterBloc(onDispose: onCounterBlocDisposed),
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
            builder: (context) => ThemeBloc(onDispose: onThemeBlocDisposed),
          ),
        );
      }
      return providers;
    }

    return MultiBlocProvider(
      providers: getProviders(),
      child: RaisedButton(
        key: Key('pop_button'),
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<Container>(builder: (context) => Container()),
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
      builder: (_, ThemeData theme) {
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
    final CounterBloc _counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        bloc: _counterBloc,
        builder: (BuildContext context, int count) {
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
  VoidCallback onDispose;

  CounterBloc({this.onDispose});

  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }

  @override
  void dispose() {
    this.onDispose?.call();
    super.dispose();
  }
}

enum ThemeEvent { toggle }

class ThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  VoidCallback onDispose;

  ThemeBloc({this.onDispose});

  @override
  ThemeData get initialState => ThemeData.light();

  @override
  Stream<ThemeData> mapEventToState(ThemeEvent event) async* {
    switch (event) {
      case ThemeEvent.toggle:
        yield currentState == ThemeData.dark()
            ? ThemeData.light()
            : ThemeData.dark();
        break;
    }
  }

  @override
  void dispose() {
    this.onDispose?.call();
    super.dispose();
  }
}

void main() {
  group('MultiBlocProvider', () {
    testWidgets('throws if initialized with no providers',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: null,
            child: Container(),
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no child',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [],
            child: null,
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('passes blocs to children', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CounterBloc>(builder: (context) => CounterBloc()),
            BlocProvider<ThemeBloc>(builder: (context) => ThemeBloc())
          ],
          child: MyApp(),
        ),
      );

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.theme, ThemeData.light());

      final Finder counterFinder = find.byKey((Key('counter_text')));
      expect(counterFinder, findsOneWidget);

      final Text counterText = tester.widget(counterFinder);
      expect(counterText.data, '0');
    });

    testWidgets('calls dispose on bloc automatically',
        (WidgetTester tester) async {
      bool counterBlocDisposed = false;
      bool themeBlocDisposed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterBlocDisposed: () {
              counterBlocDisposed = true;
            },
            onThemeBlocDisposed: () {
              themeBlocDisposed = true;
            },
          ),
        ),
      );

      expect(counterBlocDisposed, false);
      expect(themeBlocDisposed, false);

      await tester.tap(find.byKey(Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterBlocDisposed, true);
      expect(themeBlocDisposed, true);
    });

    testWidgets('does not dispose when created using value',
        (WidgetTester tester) async {
      bool counterBlocDisposed = false;
      bool themeBlocDisposed = false;

      final CounterBloc counterBloc = CounterBloc(onDispose: () {
        counterBlocDisposed = true;
      });
      final ThemeBloc themeBloc = ThemeBloc(onDispose: () {
        themeBlocDisposed = true;
      });

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            counterBlocValue: counterBloc,
            themeBlocValue: themeBloc,
          ),
        ),
      );

      expect(counterBlocDisposed, false);
      expect(themeBlocDisposed, false);

      await tester.tap(find.byKey(Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterBlocDisposed, false);
      expect(themeBlocDisposed, false);
    });
  });
}
