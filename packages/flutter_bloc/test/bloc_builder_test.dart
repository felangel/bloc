import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyAppNoBloc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeEvent, ThemeData>(
      bloc: null,
      builder: null,
    );
  }
}

class MyAppNoBuilder extends StatelessWidget {
  final ThemeBloc _themeBloc;

  MyAppNoBuilder({Key key, @required ThemeBloc themeBloc})
      : _themeBloc = themeBloc,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _themeBloc,
      builder: null,
    );
  }
}

class MyApp extends StatefulWidget {
  final Bloc<ThemeEvent, ThemeData> _themeBloc;
  final Function _onBuild;

  MyApp({
    Key key,
    @required Bloc<ThemeEvent, ThemeData> themeBloc,
    @required Function onBuild,
  })  : _themeBloc = themeBloc,
        _onBuild = onBuild,
        super(key: key);

  @override
  MyAppState createState() => MyAppState(
        themeBloc: _themeBloc,
        onBuild: _onBuild,
      );
}

class MyAppState extends State<MyApp> {
  Bloc<ThemeEvent, ThemeData> _themeBloc;
  final Function _onBuild;

  MyAppState({
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

void main() {
  group('BlocBuilder', () {
    testWidgets('throws if initialized with null bloc and builder',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyAppNoBloc(),
      );
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('throws if initialized with null builder',
        (WidgetTester tester) async {
      final ThemeBloc _themeBloc = ThemeBloc();

      await tester.pumpWidget(
        MyAppNoBuilder(
          themeBloc: _themeBloc,
        ),
      );
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('passes initial state to widget', (WidgetTester tester) async {
      final ThemeBloc _themeBloc = ThemeBloc();
      int numBuilds = 0;
      await tester.pumpWidget(
        MyApp(
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
        MyApp(
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

    testWidgets(
        'updates when the bloc is changed at runtime to a different bloc and unsubscribes from old bloc',
        (WidgetTester tester) async {
      final ThemeBloc _themeBloc = ThemeBloc();
      int numBuilds = 0;
      await tester.pumpWidget(
        MyApp(
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
        MyApp(
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
        MyApp(
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
  });
}
