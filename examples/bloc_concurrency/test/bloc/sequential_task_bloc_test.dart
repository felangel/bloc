import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ==========================================================================
  //  SEQUENTIAL BLOC TESTS
  // ==========================================================================
  group('SequentialTaskBloc', () {
    late SequentialTaskBloc bloc;

    setUp(() {
      bloc = SequentialTaskBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('should process tasks one by one ', () async {
      // Send multiple tasks quickly
      bloc
        ..add(const PerformTaskEvent(1))
        ..add(const PerformTaskEvent(2))
        ..add(const PerformTaskEvent(3));

      // Wait a bit for processing
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Should have waiting tasks
      expect(bloc.state.tasks.length, 1);

      expect(
        bloc.state.tasks.any((t) => t.status == TaskStatus.running),
        true,
      );

      // All tasks should be blue (sequential color)
      expect(
        bloc.state.tasks.every((t) => t.color == Colors.blue),
        true,
      );
    });

    test('sequential behavior - one task at a time', () async {
      // Send 3 tasks in quick succession
      for (var i = 1; i <= 3; i++) {
        bloc.add(PerformTaskEvent(i));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.tasks.length, 1);

      // First task should be running, others waiting
      expect(bloc.state.tasks.first.status, TaskStatus.running);
      expect(
        bloc.state.tasks.skip(1).every((t) => t.status == TaskStatus.waiting),
        true,
      );
    });
  });
}
