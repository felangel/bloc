import 'package:bloc_concurrency_demo/view/task_scheduler_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskSchedulerDemo Tests', () {
    testWidgets('main app renders correctly', (tester) async {
      // Set a larger screen size for testing
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TaskSchedulerDemo()),
        ),
      );

      // Wait for all animations and async operations to complete
      await tester.pumpAndSettle();

      expect(find.byType(TaskSchedulerDemo), findsOneWidget);

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
          home: Scaffold(body: TaskSchedulerDemo()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Concurrent tab
      await tester.tap(find.text('Concurrent'));
      await tester.pumpAndSettle();

      expect(find.text('Concurrent Tasks'), findsOneWidget);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('bridge tab shows perform task button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TaskSchedulerDemo()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Concurrent tab
      expect(find.textContaining('PERFORM TASK'), findsOneWidget);
      expect(find.text('CLEAR TASKS'), findsOneWidget);

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });
  });
}
