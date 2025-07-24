import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ==========================================================================
  //  THROTTLE BLOC TESTS
  // ==========================================================================

  group('ThrottleTaskBloc', () {
    late ThrottleTaskBloc bloc;

    setUp(() {
      bloc = ThrottleTaskBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test(
      'should process first event and drop subsequent ones in throttle window',
      () async {
        // Send multiple tasks quickly using TriggerTaskEvent
        bloc
          ..add(const TriggerTaskEvent(1))
          ..add(const TriggerTaskEvent(2))
          ..add(const TriggerTaskEvent(3));

        // Wait a bit for UI updates
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Should have 3 tasks: 1 processed + 2 dropped
        expect(bloc.state.tasks.length, 3);
        expect(bloc.state.totalTasksPerformed, 1); // Only first one counted

        // First task should be processed
        final processedTasks = bloc.state.tasks
            .where((task) => task.status != TaskStatus.dropped)
            .toList();
        expect(processedTasks.length, 1);
        expect(processedTasks.first.id, 1);

        // Other tasks should be dropped
        final droppedTasks = bloc.state.tasks
            .where((task) => task.status == TaskStatus.dropped)
            .toList();
        expect(droppedTasks.length, 2);
        expect(droppedTasks.map((t) => t.id).toList(), [2, 3]);
        expect(
          droppedTasks.every(
            (task) =>
                task.statusMessage == 'Dropped - Within throttle window (1s)',
          ),
          true,
        );

        // Wait for throttle period
        await Future<void>.delayed(const Duration(milliseconds: 1500));

        // Should still have same structure
        expect(bloc.state.tasks.length, 3);
        expect(bloc.state.totalTasksPerformed, 1);
      },
    );

    blocTest<ThrottleTaskBloc, TaskState>(
      'should process events separated by throttle duration',
      build: ThrottleTaskBloc.new,
      act: (bloc) async {
        bloc.add(const TriggerTaskEvent(1));
        await Future<void>.delayed(const Duration(milliseconds: 1100));
        bloc.add(const TriggerTaskEvent(2));
      },
      wait: const Duration(seconds: 3),
      verify: (bloc) {
        expect(bloc.state.totalTasksPerformed, 2);
        expect(bloc.state.tasks.length, 2);

        // Both tasks should be processed (not dropped)
        final processedTasks = bloc.state.tasks
            .where((task) => task.status != TaskStatus.dropped)
            .toList();
        expect(processedTasks.length, 2);
        expect(
          processedTasks.every((task) => task.color == Colors.indigo),
          true,
        );
      },
    );

    test('throttle behavior - first event processed, others dropped', () async {
      // Send 5 tasks rapidly using TriggerTaskEvent
      for (var i = 1; i <= 5; i++) {
        bloc.add(TriggerTaskEvent(i));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }

      // Wait a bit for UI updates
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Should have 5 tasks: 1 processed + 4 dropped
      expect(bloc.state.tasks.length, 5);
      expect(bloc.state.totalTasksPerformed, 1); // Only first one counted

      // First task should be processed
      final processedTasks = bloc.state.tasks
          .where((task) => task.status != TaskStatus.dropped)
          .toList();
      expect(processedTasks.length, 1);
      expect(processedTasks.first.id, 1);

      // Other tasks should be dropped
      final droppedTasks = bloc.state.tasks
          .where((task) => task.status == TaskStatus.dropped)
          .toList();
      expect(droppedTasks.length, 4);
      expect(droppedTasks.map((t) => t.id).toList(), [2, 3, 4, 5]);

      // Wait for throttle period
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Should still have same structure
      expect(bloc.state.tasks.length, 5);
      expect(bloc.state.totalTasksPerformed, 1);
    });

    test('should reset throttle window after timeout', () async {
      // Send first task
      bloc.add(const TriggerTaskEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Send second task (should be dropped)
      bloc.add(const TriggerTaskEvent(2));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Wait for throttle window to expire
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      // Send third task (should be processed)
      bloc.add(const TriggerTaskEvent(3));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Should have 3 tasks: 2 processed + 1 dropped
      expect(bloc.state.tasks.length, 3);
      expect(bloc.state.totalTasksPerformed, 2);

      final processedTasks = bloc.state.tasks
          .where((task) => task.status != TaskStatus.dropped)
          .toList();
      expect(processedTasks.length, 2);
      expect(processedTasks.map((t) => t.id).toList(), [1, 3]);

      final droppedTasks = bloc.state.tasks
          .where((task) => task.status == TaskStatus.dropped)
          .toList();
      expect(droppedTasks.length, 1);
      expect(droppedTasks.first.id, 2);
    });
  });
}
