import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ==========================================================================
  //  CONCURRENT BLOC TESTS
  // ==========================================================================
  group('ConcurrentTaskBloc', () {
    late ConcurrentTaskBloc bloc;

    setUp(() {
      bloc = ConcurrentTaskBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('should allow multiple tasks to run simultaneously', () async {
      // Send multiple tasks quickly
      bloc
        ..add(const PerformTaskEvent(1))
        ..add(const PerformTaskEvent(2))
        ..add(const PerformTaskEvent(3));

      // Wait a bit for processing
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // All tasks should be on timeline
      expect(bloc.state.tasks.length, 3);
      expect(bloc.state.tasks.map((t) => t.id), [1, 2, 3]);

      // All tasks should be green (concurrent color)
      expect(
        bloc.state.tasks.every((t) => t.color == Colors.green),
        true,
      );
    });

    blocTest<ConcurrentTaskBloc, TaskState>(
      'should add task with correct properties on PerformTaskEvent',
      build: ConcurrentTaskBloc.new,
      act: (bloc) => bloc.add(const PerformTaskEvent(1)),
      expect: () => [
        // Counter incremented first
        predicate<TaskState>(
          (state) => state.tasks.isEmpty && state.totalTasksPerformed == 1,
        ),
        // Task added to the list
        predicate<TaskState>(
          (state) =>
              state.tasks.length == 1 &&
              state.tasks.first.id == 1 &&
              state.tasks.first.status == TaskStatus.running &&
              state.tasks.first.color == Colors.green &&
              state.totalTasksPerformed == 1,
        ),
      ],
    );

    test('concurrent behavior - multiple tasks should not interfere', () async {
      // Send 5 tasks in quick succession
      for (var i = 1; i <= 5; i++) {
        bloc.add(PerformTaskEvent(i));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      await Future<void>.delayed(const Duration(milliseconds: 100));

      // All 5 tasks should be on timeline
      expect(bloc.state.tasks.length, 5);

      // Verify all task IDs are present
      final taskIds = bloc.state.tasks.map((t) => t.id).toList();
      expect(taskIds, [1, 2, 3, 4, 5]);
    });

    blocTest<ConcurrentTaskBloc, TaskState>(
      'should increment totalTasksPerformed for each task',
      build: ConcurrentTaskBloc.new,
      act: (bloc) => bloc.add(const PerformTaskEvent(1)),
      verify: (bloc) {
        expect(bloc.state.totalTasksPerformed, 1);
      },
    );
  });
}
