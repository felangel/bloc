import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:bloc_test/bloc_test.dart';
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

    test('should process tasks one by one', () async {
      // Send multiple tasks quickly
      bloc
        ..add(const TriggerTaskEvent(1))
        ..add(const TriggerTaskEvent(2))
        ..add(const TriggerTaskEvent(3));

      // Wait a bit for processing
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Should have 3 tasks: 1 running, 2 waiting
      expect(bloc.state.tasks.length, 3);

      expect(
        bloc.state.tasks.any((t) => t.status == TaskStatus.running),
        true,
      );

      expect(
        bloc.state.tasks.where((t) => t.status == TaskStatus.waiting).length,
        2,
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
        bloc.add(TriggerTaskEvent(i));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.tasks.length, 3);

      // First task should be running, others waiting
      expect(bloc.state.tasks.first.status, TaskStatus.running);
      expect(
        bloc.state.tasks.skip(1).every((t) => t.status == TaskStatus.waiting),
        true,
      );

      // Check that totalTasksPerformed is updated correctly
      expect(bloc.state.totalTasksPerformed, 3);
    });

    test('should add waiting tasks with correct status message', () async {
      // Add multiple tasks
      bloc
        ..add(const TriggerTaskEvent(1))
        ..add(const TriggerTaskEvent(2));

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.tasks.length, 2);
      expect(bloc.state.tasks.first.status, TaskStatus.running);
      expect(bloc.state.tasks.last.status, TaskStatus.waiting);
      expect(
        bloc.state.tasks.last.statusMessage,
        'Waiting for previous task to complete',
      );
    });

    blocTest(
      'should process first task normally when no task is running',
      build: SequentialTaskBloc.new,
      act: (bloc) => bloc.add(const TriggerTaskEvent(1)),
      verify: (bloc) {
        expect(bloc.state.totalTasksPerformed, 1);
        expect(bloc.state.tasks.length, 1);
        expect(bloc.state.tasks.first.status, TaskStatus.running);
        expect(bloc.state.tasks.first.color, Colors.blue);
      },
    );
  });
}
