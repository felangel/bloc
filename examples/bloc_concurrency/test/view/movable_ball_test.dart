import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movable_ball/view/movable_ball.dart';

void main() {
  group('MovableBallDemo Tests', () {
    testWidgets('main app renders correctly', (tester) async {
      // Set a larger screen size for testing
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MovableBallDemo()),
        ),
      );

      // Wait for all animations and async operations to complete
      await tester.pumpAndSettle();

      expect(find.byType(MovableBallDemo), findsOneWidget);

      // Test that tabs are present
      expect(find.text('Sequential'), findsOneWidget);
      expect(find.text('Concurrent'), findsOneWidget);
      expect(find.text('Droppable'), findsOneWidget);
      expect(find.text('Restartable'), findsOneWidget);
      expect(find.text('Debounce'), findsOneWidget);
      expect(find.text('Throttle'), findsOneWidget);

      // Reset surface size after test
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('can switch between tabs', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MovableBallDemo()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Concurrent tab
      await tester.tap(find.text('Concurrent'));
      await tester.pumpAndSettle();

      // Check that concurrent bridge is visible
      expect(find.text('🟢 Concurrent Bridge'), findsOneWidget);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('bridge tab shows send ball button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MovableBallDemo()),
        ),
      );

      await tester.pumpAndSettle();

      // Should find send ball button
      expect(find.textContaining('Send Ball'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });
  });
}
