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
  final bool shouldDisposeCounterBloc;
  final bool shouldDisposeThemeBloc;

  HomePage({
    Key key,
    this.onCounterBlocDisposed,
    this.onThemeBlocDisposed,
    this.shouldDisposeCounterBloc,
    this.shouldDisposeThemeBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<CounterBloc>(
          builder: (context) => CounterBloc(onDispose: onCounterBlocDisposed),
          dispose: shouldDisposeCounterBloc,
        ),
        BlocProvider<ThemeBloc>(
          builder: (context) => ThemeBloc(onDispose: onThemeBlocDisposed),
          dispose: shouldDisposeThemeBloc,
        )
      ],
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
      body: BlocBuilder<CounterEvent, int>(
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
  group('BlocProviderTree', () {
    testWidgets('throws if initialized with no BlocProviders and no child',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          BlocProviderTree(
            blocProviders: null,
            child: null,
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no bloc',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          BlocProviderTree(
            blocProviders: null,
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
          BlocProviderTree(
            blocProviders: [],
            child: null,
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('passes blocs to children', (WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProviderTree(
          blocProviders: [
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

    testWidgets('disposes blocs properly', (WidgetTester tester) async {
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

    testWidgets('does not disposes blocs if dispose = false',
        (WidgetTester tester) async {
      bool counterBlocDisposed = false;
      bool themeBlocDisposed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterBlocDisposed: () {
              counterBlocDisposed = true;
            },
            shouldDisposeCounterBloc: false,
            onThemeBlocDisposed: () {
              themeBlocDisposed = true;
            },
            shouldDisposeThemeBloc: false,
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
