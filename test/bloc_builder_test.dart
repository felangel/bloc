import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc/bloc.dart';

class MyAppNoBloc extends StatelessWidget {
  final ThemeBloc _themeBloc;

  MyAppNoBloc({Key key, @required ThemeBloc themeBloc})
      : _themeBloc = themeBloc,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeData>(
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

class MyApp extends StatelessWidget {
  final ThemeBloc _themeBloc;

  MyApp({Key key, @required ThemeBloc themeBloc})
      : _themeBloc = themeBloc,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _themeBloc,
      builder: ((
        BuildContext context,
        ThemeData theme,
      ) {
        return MaterialApp(
          key: Key('material_app'),
          theme: theme,
          home: Container(),
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
  Stream<ThemeData> mapEventToState(event) async* {
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
      final ThemeBloc _themeBloc = ThemeBloc();

      await tester.pumpWidget(
        MyAppNoBloc(
          themeBloc: _themeBloc,
        ),
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
      await tester.pumpWidget(
        MyApp(
          themeBloc: _themeBloc,
        ),
      );

      MaterialApp _materialApp =
          find.byKey(Key('material_app')).evaluate().first.widget;
      expect(_materialApp.theme, ThemeData.light());
    });

    testWidgets('receives events and sends state updates to widget',
        (WidgetTester tester) async {
      final ThemeBloc _themeBloc = ThemeBloc();
      await tester.pumpWidget(
        MyApp(
          themeBloc: _themeBloc,
        ),
      );

      _themeBloc.dispatch(SetDarkTheme());

      await tester.pumpAndSettle();

      MaterialApp _materialApp =
          find.byKey(Key('material_app')).evaluate().first.widget;

      expect(_materialApp.theme, ThemeData.dark());
    });
  });
}
