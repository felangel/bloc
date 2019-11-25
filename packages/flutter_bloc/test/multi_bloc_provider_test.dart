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
            builder: (context) => CounterBloc(onClose: onCounterBlocClosed),
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
            builder: (context) => ThemeBloc(onClose: onThemeBlocClosed),
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
    final counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        bloc: counterBloc,
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
  VoidCallback onClose;

  CounterBloc({this.onClose});

  @override
  int get initialState => 0;

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
  VoidCallback onClose;

  ThemeBloc({this.onClose});

  @override
  ThemeData get initialState => ThemeData.light();

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
    testWidgets('throws if initialized with no providers',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: null,
            child: Container(),
          ),
        );
      } on Object catch (error) {
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
      } on Object catch (error) {
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

      final materialApp =
          tester.widget(find.byType(MaterialApp)) as MaterialApp;
      expect(materialApp.theme, ThemeData.light());

      final counterFinder = find.byKey((Key('counter_text')));
      expect(counterFinder, findsOneWidget);

      final counterText = tester.widget(counterFinder) as Text;
      expect(counterText.data, '0');
    });

    testWidgets('calls close on bloc automatically',
        (WidgetTester tester) async {
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

      expect(counterBlocClosed, true);
      expect(themeBlocClosed, true);
    });

    testWidgets('does not close when created using value',
        (WidgetTester tester) async {
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
