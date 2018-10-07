import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  final ThemeBloc _themeBloc = ThemeBloc();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: _themeBloc.initialData,
      stream: _themeBloc.state,
      builder: ((
        BuildContext context,
        AsyncSnapshot<ThemeData> snapshot,
      ) {
        final _theme = snapshot.data;
        final IconData icon = (_theme == ThemeData.light())
            ? Icons.brightness_4
            : Icons.brightness_7;

        return MaterialApp(
          title: 'Flutter Demo',
          theme: _theme,
          home: Scaffold(
            appBar: AppBar(title: Text('ThemeBloc Demo')),
            body: ListView(
              children: [
                ListTile(
                  leading: Icon(icon),
                  title: Text('Dark Theme'),
                  trailing: Switch(
                    value: _theme == ThemeData.dark(),
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

  @override
  void dispose() {
    super.dispose();
    _themeBloc.dispose();
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
      event.add(SetDarkTheme());
    } else {
      _currentTheme = ThemeData.light();
      event.add(SetLightTheme());
    }
  }

  ThemeData get initialData => _currentTheme;

  @override
  Stream<ThemeData> mapEventToState(event) async* {
    if (event is SetDarkTheme) {
      yield _darkTheme;
    } else {
      yield _lightTheme;
    }
  }
}
