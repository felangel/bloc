import 'package:flutter/material.dart';
import 'package:flutter_timer/timer/timer.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(109, 234, 255, 1),
        colorScheme: ColorScheme.dark(
          secondary: Color.fromRGBO(72, 74, 126, 1),
        ),
      ),
      title: 'Flutter Timer',
      home: const TimerPage(),
    );
  }
}
