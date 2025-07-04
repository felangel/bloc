import 'package:flutter/material.dart';
import 'package:movable_ball/view/movable_ball.dart';

void main() {
  runApp(const MyApp());
}

/// Main application widget
class MyApp extends StatelessWidget {
  /// Creates an instance of [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloc Concurrency Demo - Movable Balls',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MovableBallDemo(),
    );
  }
}
