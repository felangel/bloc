import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ==========================================================================
  //  DROPPABLE BLOC TESTS
  // ==========================================================================

  group('DroppableTaskBloc', () {
    late DroppableTaskBloc bloc;

    setUp(() {
      bloc = DroppableTaskBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('should drop new tasks when one is already running', () async {
      // Send first task
      bloc.add(const TriggerTaskEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Send more tasks quickly
      bloc
        ..add(const TriggerTaskEvent(2))
        ..add(const TriggerTaskEvent(3));

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.tasks.length, 3);

      // First task should be running
      expect(bloc.state.tasks.first.status, TaskStatus.running);

      // Subsequent tasks should be dropped
      expect(
        bloc.state.tasks.skip(1).every((t) => t.status == TaskStatus.dropped),
        true,
      );

      // All tasks should be orange (droppable color)
      expect(
        bloc.state.tasks.every((t) => t.color == Colors.orange),
        true,
      );
    });

    blocTest(
      'should process first task normally when no task is running',
      build: DroppableTaskBloc.new,
      act: (bloc) => bloc.add(const TriggerTaskEvent(1)),
      verify: (bloc) {
        expect(bloc.state.totalTasksPerformed, 1);
        expect(bloc.state.tasks.length, 1);
        expect(bloc.state.tasks.first.status, TaskStatus.running);
        expect(bloc.state.tasks.first.color, Colors.orange);
      },
    );

    test('should immediately drop tasks when another is running', () async {
      // Start first task
      bloc.add(const TriggerTaskEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Try to add another task while first is running
      bloc.add(const TriggerTaskEvent(2));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.tasks.length, 2);
      expect(bloc.state.tasks.first.status, TaskStatus.running);
      expect(bloc.state.tasks.last.status, TaskStatus.dropped);
      expect(
        bloc.state.tasks.last.statusMessage,
        'Dropped - Another task is running',
      );
    });
  });
}
