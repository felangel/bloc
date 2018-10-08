import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final ThemeBloc _themeBloc = ThemeBloc();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _themeBloc,
      builder: ((
        BuildContext context,
        ThemeData theme,
      ) {
        final IconData icon = (theme == ThemeData.light())
            ? Icons.brightness_4
            : Icons.brightness_7;

        return MaterialApp(
          title: 'Flutter Demo',
          theme: theme,
          home: Scaffold(
            appBar: AppBar(title: Text('ThemeBloc Demo')),
            body: ListView(
              children: [
                ListTile(
                  leading: Icon(icon),
                  title: Text('Dark Theme'),
                  trailing: Switch(
                    value: theme == ThemeData.dark(),
                    onChanged: (value) => _themeBloc.toggleTheme(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class SetDarkTheme {}

class SetLightTheme {}

class ThemeBloc extends Bloc<ThemeData> {
  final ThemeData _darkTheme = ThemeData.dark();
  final ThemeData _lightTheme = ThemeData.light();
  ThemeData _currentTheme = ThemeData.light();

  void toggleTheme() {
    if (_currentTheme == ThemeData.light()) {
      _currentTheme = ThemeData.dark();
      dispatch(SetDarkTheme());
    } else {
      _currentTheme = ThemeData.light();
      dispatch(SetLightTheme());
    }
  }

  ThemeData get initialState => _currentTheme;

  @override
  Stream<ThemeData> mapEventToState(event) async* {
    if (event is SetDarkTheme) {
      yield _darkTheme;
    } else {
      yield _lightTheme;
    }
  }
}
