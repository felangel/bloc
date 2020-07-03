import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

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
      builder: ((context, theme) {
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
  ThemeBloc() : super(ThemeData.light());

  @override
  Stream<ThemeData> mapEventToState(ThemeEvent event) async* {
    yield event is SetDarkTheme ? ThemeData.dark() : ThemeData.light();
  }
}

class DarkThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  DarkThemeBloc() : super(ThemeData.dark());

  @override
  Stream<ThemeData> mapEventToState(ThemeEvent event) async* {
    yield event is SetDarkTheme ? ThemeData.dark() : ThemeData.light();
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
              buildWhen: (previousState, state) {
                return (previousState + state) % 3 == 0;
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
                _bloc.add(CounterEvent.increment);
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
  CounterBloc() : super(0);

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
}

void main() {
  group('BlocBuilder', () {
    testWidgets('throws if initialized with null bloc and builder',
        (tester) async {
      try {
        await tester.pumpWidget(
          BlocBuilder<ThemeBloc, ThemeData>(
            bloc: null,
            builder: null,
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with null builder', (tester) async {
      try {
        await tester.pumpWidget(
          BlocBuilder<ThemeBloc, ThemeData>(
            bloc: ThemeBloc(),
            builder: null,
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('passes initial state to widget', (tester) async {
      final _themeBloc = ThemeBloc();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeBloc: _themeBloc,
          onBuild: () {
            numBuilds++;
          },
        ),
      );

      final _materialApp = find
          .byKey(Key('material_app'))
          .evaluate()
          .first
          .widget as MaterialApp;
      expect(_materialApp.theme, ThemeData.light());
      expect(numBuilds, 1);
    });

    testWidgets('receives events and sends state updates to widget',
        (tester) async {
      final _themeBloc = ThemeBloc();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeBloc: _themeBloc,
          onBuild: () {
            numBuilds++;
          },
        ),
      );

      _themeBloc.add(SetDarkTheme());

      await tester.pumpAndSettle();

      final _materialApp = find
          .byKey(Key('material_app'))
          .evaluate()
          .first
          .widget as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);
    });

    testWidgets('infers the bloc from the context if the bloc is not provided',
        (tester) async {
      final themeBloc = ThemeBloc();
      var numBuilds = 0;
      await tester.pumpWidget(
        BlocProvider.value(
          value: themeBloc,
          child: BlocBuilder<ThemeBloc, ThemeData>(
            builder: (
              context,
              theme,
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

      themeBloc.add(SetDarkTheme());

      await tester.pump();

      var _materialApp = find.byKey(Key('material_app')).evaluate().first.widget
          as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      themeBloc.add(SetLightTheme());

      await tester.pump();

      _materialApp = find.byKey(Key('material_app')).evaluate().first.widget
          as MaterialApp;

      expect(_materialApp.theme, ThemeData.light());
      expect(numBuilds, 3);
    });

    testWidgets(
        'updates when the bloc is changed at runtime to a different bloc and'
        'unsubscribes from old bloc', (tester) async {
      final _themeBloc = ThemeBloc();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeBloc: _themeBloc,
          onBuild: () {
            numBuilds++;
          },
        ),
      );

      await tester.pumpAndSettle();

      var _materialApp = find.byKey(Key('material_app')).evaluate().first.widget
          as MaterialApp;

      expect(_materialApp.theme, ThemeData.light());
      expect(numBuilds, 1);

      await tester.tap(find.byKey(Key('raised_button_1')));
      await tester.pumpAndSettle();

      _materialApp = find.byKey(Key('material_app')).evaluate().first.widget
          as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      _themeBloc.add(SetLightTheme());
      await tester.pumpAndSettle();

      _materialApp = find.byKey(Key('material_app')).evaluate().first.widget
          as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);
    });

    testWidgets(
        'does not update when the bloc is changed at runtime to same bloc '
        'and stays subscribed to current bloc', (tester) async {
      final _themeBloc = DarkThemeBloc();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeBloc: _themeBloc,
          onBuild: () {
            numBuilds++;
          },
        ),
      );

      await tester.pumpAndSettle();

      var _materialApp = find.byKey(Key('material_app')).evaluate().first.widget
          as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 1);

      await tester.tap(find.byKey(Key('raised_button_2')));
      await tester.pumpAndSettle();

      _materialApp = find.byKey(Key('material_app')).evaluate().first.widget
          as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      _themeBloc.add(SetLightTheme());
      await tester.pumpAndSettle();

      _materialApp = find.byKey(Key('material_app')).evaluate().first.widget
          as MaterialApp;

      expect(_materialApp.theme, ThemeData.light());
      expect(numBuilds, 3);
    });

    testWidgets('shows latest state instead of initial state', (tester) async {
      final _themeBloc = ThemeBloc();
      _themeBloc.add(SetDarkTheme());
      await tester.pumpAndSettle();

      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeBloc: _themeBloc,
          onBuild: () {
            numBuilds++;
          },
        ),
      );

      await tester.pumpAndSettle();

      final _materialApp = find
          .byKey(Key('material_app'))
          .evaluate()
          .first
          .widget as MaterialApp;

      expect(_materialApp.theme, ThemeData.dark());
      expect(numBuilds, 1);
    });

    testWidgets('with buildWhen only rebuilds when buildWhen evaluates to true',
        (tester) async {
      await tester.pumpWidget(MyCounterApp());
      await tester.pumpAndSettle();

      expect(find.byKey(Key('myCounterApp')), findsOneWidget);

      final incrementButtonFinder =
          find.byKey(Key('myCounterAppIncrementButton'));
      expect(incrementButtonFinder, findsOneWidget);

      final counterText1 =
          tester.widget(find.byKey(Key('myCounterAppText'))) as Text;
      expect(counterText1.data, '0');

      final conditionalCounterText1 =
          tester.widget(find.byKey(Key('myCounterAppTextCondition'))) as Text;
      expect(conditionalCounterText1.data, '0');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final counterText2 =
          tester.widget(find.byKey(Key('myCounterAppText'))) as Text;
      expect(counterText2.data, '1');

      final conditionalCounterText2 =
          tester.widget(find.byKey(Key('myCounterAppTextCondition'))) as Text;
      expect(conditionalCounterText2.data, '0');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final counterText3 =
          tester.widget(find.byKey(Key('myCounterAppText'))) as Text;
      expect(counterText3.data, '2');

      final conditionalCounterText3 =
          tester.widget(find.byKey(Key('myCounterAppTextCondition'))) as Text;
      expect(conditionalCounterText3.data, '2');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final counterText4 =
          tester.widget(find.byKey(Key('myCounterAppText'))) as Text;
      expect(counterText4.data, '3');

      final conditionalCounterText4 =
          tester.widget(find.byKey(Key('myCounterAppTextCondition'))) as Text;
      expect(conditionalCounterText4.data, '2');
    });
  });
}
