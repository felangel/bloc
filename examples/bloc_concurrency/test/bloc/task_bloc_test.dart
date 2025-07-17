import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Task Execution Simulation', () {
    late ConcurrentTaskBloc bloc;

    setUp(() {
      bloc = ConcurrentTaskBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('should create running task with correct properties', () async {
      bloc.add(const PerformTaskEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.tasks.length, 1);
      final task = bloc.state.tasks.first;
      expect(task.id, 1);
      expect(task.status, TaskStatus.running);
      expect(task.duration, const Duration(seconds: 2));
      expect(task.color, Colors.green);
      expect(task.startTime, isA<DateTime>());
    });

    test('should update existing task instead of creating new one', () async {
      // Create initial task
      bloc.add(const PerformTaskEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.tasks.length, 1);

      // Add same task ID again (for testing purposes)
      bloc.add(const PerformTaskEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Should still have only one task
      expect(bloc.state.tasks.length, 1);
    });
  });

  group('Edge Cases', () {
    test('should handle rapid event addition without memory leaks', () async {
      final bloc = ConcurrentTaskBloc();

      // Add many events rapidly
      for (var i = 0; i < 100; i++) {
        bloc.add(PerformTaskEvent(i));
      }

      await Future<void>.delayed(const Duration(seconds: 1));

      expect(bloc.state.totalTasksPerformed, 100);
      expect(bloc.state.tasks.length, 100);

      await bloc.close();
    });
  });
}
