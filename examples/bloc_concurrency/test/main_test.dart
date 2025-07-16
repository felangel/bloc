import 'package:bloc_concurrency_demo/view/task_scheduler_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('main ...', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TaskSchedulerDemo()),
      ),
    );
    expect(find.byType(TaskSchedulerDemo), findsOneWidget);
  });
}
