import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ==========================================================================
  //  DEBOUNCE BLOC TESTS
  // ==========================================================================
  group('DebounceTaskBloc', () {
    late DebounceTaskBloc bloc;

    setUp(() {
      bloc = DebounceTaskBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test(
      'should show waiting tasks immediately and debounce actual processing',
      () async {
        // Send multiple tasks quickly using TriggerTaskEvent
        bloc
          ..add(const TriggerTaskEvent(1))
          ..add(const TriggerTaskEvent(2))
          ..add(const TriggerTaskEvent(3));

        // Wait a bit for UI updates
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Should have 3 waiting tasks immediately
        expect(bloc.state.tasks.length, 3);
        expect(bloc.state.totalTasksPerformed, 3);
        expect(
          bloc.state.tasks.every((task) => task.status == TaskStatus.waiting),
          true,
        );
        expect(
          bloc.state.tasks.every(
            (task) =>
                task.statusMessage ==
                'Waiting for debounce period to complete (2s)',
          ),
          true,
        );

        // Wait for debounce to complete
        await Future<void>.delayed(const Duration(milliseconds: 2500));

        // Should have only 1 running/finished task (the last one)
        final processedTasks = bloc.state.tasks
            .where((task) => task.status != TaskStatus.waiting)
            .toList();
        expect(processedTasks.length, 1);
        expect(processedTasks.first.id, 3);
        expect(processedTasks.first.color, Colors.deepOrange);
      },
    );

    blocTest<DebounceTaskBloc, TaskState>(
      'should process events separated by debounce duration',
      build: DebounceTaskBloc.new,
      act: (bloc) async {
        bloc.add(const TriggerTaskEvent(1));
        await Future<void>.delayed(const Duration(milliseconds: 2100));
        bloc.add(const TriggerTaskEvent(2));
      },
      wait: const Duration(seconds: 5),
      verify: (bloc) {
        expect(bloc.state.totalTasksPerformed, 2);
        expect(bloc.state.tasks.length, 2);

        // Both tasks should be processed (not waiting)
        final processedTasks = bloc.state.tasks
            .where((task) => task.status != TaskStatus.waiting)
            .toList();
        expect(processedTasks.length, 2);
        expect(
          processedTasks.every((task) => task.color == Colors.deepOrange),
          true,
        );
      },
    );

    test(
      'debounce behavior - shows all waiting tasks but processes only last',
      () async {
        // Send 5 tasks rapidly using TriggerTaskEvent
        for (var i = 1; i <= 5; i++) {
          bloc.add(TriggerTaskEvent(i));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }

        // Should show 5 waiting tasks immediately
        expect(bloc.state.tasks.length, 5);
        expect(bloc.state.totalTasksPerformed, 5);
        expect(
          bloc.state.tasks.every((task) => task.status == TaskStatus.waiting),
          true,
        );

        // Wait for debounce to complete
        await Future<void>.delayed(const Duration(milliseconds: 2500));

        // Should have only 1 processed task (the last one)
        final processedTasks = bloc.state.tasks
            .where((task) => task.status != TaskStatus.waiting)
            .toList();
        expect(processedTasks.length, 1);
        expect(processedTasks.first.id, 5);
      },
    );
  });
}
