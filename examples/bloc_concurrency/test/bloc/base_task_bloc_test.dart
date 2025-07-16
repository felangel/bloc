import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BaseTaskBloc', () {
    late BaseTaskBloc bloc;

    setUp(() {
      // Using ConcurrentTaskBloc as concrete implementation of BaseTaskBloc
      bloc = ConcurrentTaskBloc();
    });

    tearDown(() {
      bloc.close();
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        expect(bloc.state, const TaskState(tasks: [], totalTasksPerformed: 0));
      });
    });

    group('ClearTasksEvent', () {
      blocTest<BaseTaskBloc, TaskState>(
        'should clear all tasks and reset counter',
        build: ConcurrentTaskBloc.new,
        act: (bloc) async {
          // First add some tasks
          bloc.add(const PerformTaskEvent(1));
          await Future<void>.delayed(const Duration(milliseconds: 100));
          bloc.add(const ClearTasksEvent());
        },
        wait: const Duration(milliseconds: 200),
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
          // Timeline cleared
          predicate<TaskState>(
            (state) => state.tasks.isEmpty && state.totalTasksPerformed == 0,
          ),
        ],
        verify: (bloc) {
          expect(bloc.state.tasks.isEmpty, true);
          expect(bloc.state.totalTasksPerformed, 0);
        },
      );
    });

    group('UpdateTaskStatusEvent', () {
      blocTest<BaseTaskBloc, TaskState>(
        'should update task status correctly',
        build: ConcurrentTaskBloc.new,
        seed: () => const TaskState(
          tasks: [
            Task(
              id: 1,
              status: TaskStatus.running,
              duration: Duration(seconds: 2),
              color: Colors.green,
            ),
          ],
          totalTasksPerformed: 1,
        ),
        act: (bloc) =>
            bloc.add(const UpdateTaskStatusEvent(1, TaskStatus.finished)),
        expect: () => [
          predicate<TaskState>(
            (state) =>
                state.tasks.length == 1 &&
                state.tasks.first.id == 1 &&
                state.tasks.first.status == TaskStatus.finished &&
                state.totalTasksPerformed == 1,
          ),
        ],
      );
    });
  });
}
