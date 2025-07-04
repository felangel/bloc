import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movable_ball/view/movable_ball.dart';

void main() {
  testWidgets('main ...', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MovableBallDemo()),
      ),
    );
    expect(find.byType(MovableBallDemo), findsOneWidget);
  });
}
