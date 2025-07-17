import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ==========================================================================
  //  RESTARTABLE BLOC TESTS
  // ==========================================================================

  group('RestartableTaskBloc', () {
    late RestartableTaskBloc bloc;

    setUp(() {
      bloc = RestartableTaskBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('should cancel previous tasks and start new one', () async {
      // Send first task
      bloc.add(const PerformTaskEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Send second task (should restart)
      bloc.add(const PerformTaskEvent(2));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Should have 2 tasks
      expect(bloc.state.tasks.length, 2);

      // First task should be cancelled, second running
      expect(bloc.state.tasks.first.status, TaskStatus.cancelled);
      expect(bloc.state.tasks.last.status, TaskStatus.running);

      // All tasks should be purple (restartable color)
      expect(
        bloc.state.tasks.every((t) => t.color == Colors.purple),
        true,
      );
    });

    blocTest<RestartableTaskBloc, TaskState>(
      'should process single task normally',
      build: RestartableTaskBloc.new,
      act: (bloc) => bloc.add(const PerformTaskEvent(1)),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.totalTasksPerformed, 1);
        expect(bloc.state.tasks.length, 1);
        expect(bloc.state.tasks.first.status, TaskStatus.running);
        expect(bloc.state.tasks.first.color, Colors.purple);
      },
    );

    test('restartable behavior - multiple restarts should work', () async {
      // Send 3 tasks in quick succession
      for (var i = 1; i <= 3; i++) {
        bloc.add(PerformTaskEvent(i));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }

      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Should have 3 tasks
      expect(bloc.state.tasks.length, 3);

      // First two should be cancelled, last one running
      expect(
        bloc.state.tasks.take(2).every((t) => t.status == TaskStatus.cancelled),
        true,
      );
      expect(bloc.state.tasks.last.status, TaskStatus.running);
    });
  });
}
