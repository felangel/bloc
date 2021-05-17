import 'package:flutter/material.dart';
import 'package:flutter_bloc_with_stream/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TickerApp', () {
    testWidgets('is a MaterialApp', (tester) async {
      expect(TickerApp(), isA<MaterialApp>());
    });

    testWidgets('renders TickerPage', (tester) async {
      await tester.pumpWidget(TickerApp());
      expect(find.byType(TickerPage), findsOneWidget);
    });
  });
}
