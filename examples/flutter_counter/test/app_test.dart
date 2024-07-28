// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_counter/app.dart';
import 'package:flutter_counter/counter/counter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(CounterApp, () {
    testWidgets('is a $MaterialApp', (tester) async {
      expect(CounterApp(), isA<MaterialApp>());
    });

    testWidgets('home is $CounterPage', (tester) async {
      expect(CounterApp().home, isA<CounterPage>());
    });

    testWidgets('renders $CounterPage', (tester) async {
      await tester.pumpWidget(CounterApp());
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
