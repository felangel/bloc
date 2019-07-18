import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyThemeApp extends StatefulWidget {
  final Bloc<ThemeEvent, ThemeData> _themeBloc;
  final Function _onBuild;

  MyThemeApp({
    Key key,
    @required Bloc<ThemeEvent, ThemeData> themeBloc,
    @required Function onBuild,
  })  : _themeBloc = themeBloc,
        _onBuild = onBuild,
        super(key: key);

  @override
  State<MyThemeApp> createState() => MyThemeAppState(
        themeBloc: _themeBloc,
        onBuild: _onBuild,
      );
}

class MyThemeAppState extends State<MyThemeApp> {
  Bloc<ThemeEvent, ThemeData> _themeBloc;
  final Function _onBuild;

  MyThemeAppState({
    Key key,
    @required Bloc<ThemeEvent, ThemeData> themeBloc,
    @required Function onBuild,
  })  : _themeBloc = themeBloc,
        _onBuild = onBuild;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _themeBloc,
      builder: ((
        BuildContext context,
        ThemeData theme,
      ) {
        _onBuild();
        return MaterialApp(
          key: Key('material_app'),
          theme: theme,
          home: Column(
            children: [
              RaisedButton(
                key: Key('raised_button_1'),
                onPressed: () {
                  setState(() {
                    _themeBloc = DarkThemeBloc();
                  });
                },
              ),
              RaisedButton(
                key: Key('raised_button_2'),
                onPressed: () {
                  setState(() {
                    _themeBloc = _themeBloc;
                  });
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}

abstract class ThemeEvent {}

class SetDarkTheme extends ThemeEvent {}

class SetLightTheme extends ThemeEvent {}

class ThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  final ThemeData _darkTheme = ThemeData.dark();
  final ThemeData _lightTheme = ThemeData.light();

  ThemeData get initialState => _lightTheme;

  @override
  Stream<ThemeData> mapEventToState(ThemeEvent event) async* {
    if (event is SetDarkTheme) {
      yield _darkTheme;
    } else {
      yield _lightTheme;
    }
  }
}

class DarkThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  final ThemeData _darkTheme = ThemeData.dark();
  final ThemeData _lightTheme = ThemeData.light();

  ThemeData get initialState => _darkTheme;

  @override
  Stream<ThemeData> mapEventToState(ThemeEvent event) async* {
    if (event is SetDarkTheme) {
      yield _darkTheme;
    } else {
      yield _lightTheme;
    }
  }
}

class MyCounterApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyCounterAppState();
}

class MyCounterAppState extends State<MyCounterApp> {
  final CounterBloc _bloc = CounterBloc();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: Key('myCounterApp'),
        body: Column(
          children: <Widget>[
            BlocBuilder<CounterBloc, int>(
              bloc: _bloc,
              condition: (previousState, currentState) {
                return (previousState + currentState) % 3 == 0;
              },
              builder: (context, count) {
                return Text('$count', key: Key('myCounterAppTextCondition'));
              },
            ),
            BlocBuilder<CounterBloc, int>(
              bloc: _bloc,
              builder: (context, count) {
                return Text('$count', key: Key('myCounterAppText'));
              },
            ),
            RaisedButton(
              key: Key('myCounterAppIncrementButton'),
              onPressed: () {
                _bloc.dispatch(CounterEvent.increment);
              },
            )
          ],
        ),
      ),
    );
  }
}

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
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
}

void main() {
  group('BlocBuilder', () {
    testWidgets('throws if initialized with null bloc and builder',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          BlocBuilder<ThemeBloc, ThemeData>(
            bloc: null,
            builder: null,
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with null builder',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          BlocBuilder<ThemeBloc, ThemeData>(
            bloc: ThemeBloc(),
            builder: null,
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('passes initial state to widget', (WidgetTester tester) async {
      final ThemeBloc _themeBloc = ThemeBloc();
      int numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeBloc: _themeBloc,
          onBuild: () {
            numBuilds++;
          },
        ),
      );

      MaterialApp _materialApp = find
          .byKey(Key('material_app'))
          .evaluate()
          .first
          .widget as MaterialApp;
      expect(_materialApp.theme, ThemeData.light());
      expect(numBuilds, 1);
    });

    testWidgets('receives events and sends state updates to widget',
        (WidgetTester tester) async {
      final ThemeBloc _themeBloc = ThemeBloc();
      int numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeBloc: _themeBloc,
          onBuild: () {
            numBuilds++;
          },
        ),
      );

      _themeBloc.dispatch(SetDarkTheme());

      await tester.pumpAndSettle();

      MaterialApp _materialApp = find
          .byKey(Key('material_app'))
          .evaluate()
          .first
          .widget as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);
    });

    testWidgets('infers the bloc from the context if the bloc is not provided',
        (WidgetTester tester) async {
      final ThemeBloc themeBloc = ThemeBloc();
      int numBuilds = 0;
      await tester.pumpWidget(
        BlocProvider.value(
          value: themeBloc,
          child: BlocBuilder<ThemeBloc, ThemeData>(
            builder: (
              BuildContext context,
              ThemeData theme,
            ) {
              numBuilds++;
              return MaterialApp(
                key: Key('material_app'),
                theme: theme,
                home: Container(),
              );
            },
          ),
        ),
      );

      themeBloc.dispatch(SetDarkTheme());

      await tester.pumpAndSettle();

      MaterialApp _materialApp = find
          .byKey(Key('material_app'))
          .evaluate()
          .first
          .widget as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      themeBloc.dispatch(SetLightTheme());

      await tester.pumpAndSettle();

      _materialApp = find.byKey(Key('material_app')).evaluate().first.widget
          as MaterialApp;

      expect(_materialApp.theme, ThemeData.light());
      expect(numBuilds, 3);
    });

    testWidgets(
        'updates when the bloc is changed at runtime to a different bloc and unsubscribes from old bloc',
        (WidgetTester tester) async {
      final ThemeBloc _themeBloc = ThemeBloc();
      int numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeBloc: _themeBloc,
          onBuild: () {
            numBuilds++;
          },
        ),
      );

      await tester.pumpAndSettle();

      MaterialApp _materialApp = find
          .byKey(Key('material_app'))
          .evaluate()
          .first
          .widget as MaterialApp;

      expect(_materialApp.theme, ThemeData.light());
      expect(numBuilds, 1);

      await tester.tap(find.byKey(Key('raised_button_1')));
      await tester.pumpAndSettle();

      _materialApp = find.byKey(Key('material_app')).evaluate().first.widget
          as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      _themeBloc.dispatch(SetLightTheme());
      await tester.pumpAndSettle();

      _materialApp = find.byKey(Key('material_app')).evaluate().first.widget
          as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);
    });

    testWidgets(
        'does not update when the bloc is changed at runtime to same bloc and stays subscribed to current bloc',
        (WidgetTester tester) async {
      final DarkThemeBloc _themeBloc = DarkThemeBloc();
      int numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeBloc: _themeBloc,
          onBuild: () {
            numBuilds++;
          },
        ),
      );

      await tester.pumpAndSettle();

      MaterialApp _materialApp = find
          .byKey(Key('material_app'))
          .evaluate()
          .first
          .widget as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 1);

      await tester.tap(find.byKey(Key('raised_button_2')));
      await tester.pumpAndSettle();

      _materialApp = find.byKey(Key('material_app')).evaluate().first.widget
          as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      _themeBloc.dispatch(SetLightTheme());
      await tester.pumpAndSettle();

      _materialApp = find.byKey(Key('material_app')).evaluate().first.widget
          as MaterialApp;

      expect(_materialApp.theme, ThemeData.light());
      expect(numBuilds, 3);
    });

    testWidgets('shows latest state instead of initial state',
        (WidgetTester tester) async {
      final ThemeBloc _themeBloc = ThemeBloc();
      _themeBloc.dispatch(SetDarkTheme());
      await tester.pumpAndSettle();

      int numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeBloc: _themeBloc,
          onBuild: () {
            numBuilds++;
          },
        ),
      );

      await tester.pumpAndSettle();

      MaterialApp _materialApp = find
          .byKey(Key('material_app'))
          .evaluate()
          .first
          .widget as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 1);
    });

    testWidgets('with condition only rebuilds when condition evaluates to true',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyCounterApp());
      await tester.pumpAndSettle();

      expect(find.byKey(Key('myCounterApp')), findsOneWidget);

      final incrementButtonFinder =
          find.byKey(Key('myCounterAppIncrementButton'));
      expect(incrementButtonFinder, findsOneWidget);

      final Text counterText1 =
          tester.widget(find.byKey(Key('myCounterAppText')));
      expect(counterText1.data, '0');

      final Text conditionalCounterText1 =
          tester.widget(find.byKey(Key('myCounterAppTextCondition')));
      expect(conditionalCounterText1.data, '0');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final Text counterText2 =
          tester.widget(find.byKey(Key('myCounterAppText')));
      expect(counterText2.data, '1');

      final Text conditionalCounterText2 =
          tester.widget(find.byKey(Key('myCounterAppTextCondition')));
      expect(conditionalCounterText2.data, '0');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final Text counterText3 =
          tester.widget(find.byKey(Key('myCounterAppText')));
      expect(counterText3.data, '2');

      final Text conditionalCounterText3 =
          tester.widget(find.byKey(Key('myCounterAppTextCondition')));
      expect(conditionalCounterText3.data, '2');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final Text counterText4 =
          tester.widget(find.byKey(Key('myCounterAppText')));
      expect(counterText4.data, '3');

      final Text conditionalCounterText4 =
          tester.widget(find.byKey(Key('myCounterAppTextCondition')));
      expect(conditionalCounterText4.data, '2');
    });
  });
}
