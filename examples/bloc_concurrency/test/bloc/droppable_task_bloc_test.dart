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
      bloc.add(const PerformTaskEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Send more tasks quickly
      bloc
        ..add(const PerformTaskEvent(2))
        ..add(const PerformTaskEvent(3));

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.tasks.length, 1);

      // First task should be running, others dropped
      expect(bloc.state.tasks.first.status, TaskStatus.running);
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

    blocTest<DroppableTaskBloc, TaskState>(
      'should process first task normally when no task is running',
      build: DroppableTaskBloc.new,
      act: (bloc) => bloc.add(const PerformTaskEvent(1)),
      verify: (bloc) {
        expect(bloc.state.totalTasksPerformed, 1);
        expect(bloc.state.tasks.length, 1);
        expect(bloc.state.tasks.first.status, TaskStatus.running);
        expect(bloc.state.tasks.first.color, Colors.orange);
      },
    );
  });
}
