import 'package:flutter/material.dart';
import 'package:flutter_timer/timer/timer.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Set global FAB theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 50, 42, 83),
          foregroundColor: Colors.white,
        ),
      ),
      home: const TimerPage(),
    );
  }
}
