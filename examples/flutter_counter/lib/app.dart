import 'package:flutter/material.dart';
import 'package:flutter_counter/counter_list/counter_list_screen.dart';

import 'counter/counter.dart';

/// {@template counter_app}
/// A [MaterialApp] which sets the `home` to [CounterPage].
/// {@endtemplate}
class CounterApp extends MaterialApp {
  /// {@macro counter_app}
  const CounterApp({Key? key}) : super(key: key, home: const CounterListScreen());
}
