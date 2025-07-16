import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
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
      'should debounce rapid events and only process the last one',
      () async {
        // Send multiple tasks quickly
        bloc
          ..add(const PerformTaskEvent(1))
          ..add(const PerformTaskEvent(2))
          ..add(const PerformTaskEvent(3));

        // Wait for debounce to complete
        await Future<void>.delayed(const Duration(milliseconds: 2500));

        // Should have only 1 task (the last one)
        expect(bloc.state.tasks.length, 1);
        expect(bloc.state.tasks.first.id, 3);
        expect(bloc.state.tasks.first.color, Colors.deepOrange);
        expect(bloc.state.totalTasksPerformed, 1);
      },
    );

    blocTest<DebounceTaskBloc, TaskState>(
      'should process events separated by debounce duration',
      build: DebounceTaskBloc.new,
      act: (bloc) async {
        bloc.add(const PerformTaskEvent(1));
        await Future<void>.delayed(const Duration(milliseconds: 2100));
        bloc.add(const PerformTaskEvent(2));
      },
      wait: const Duration(seconds: 5),
      verify: (bloc) {
        expect(bloc.state.totalTasksPerformed, 2);
        expect(bloc.state.tasks.length, 2);
        expect(
          bloc.state.tasks.every((task) => task.color == Colors.deepOrange),
          true,
        );
      },
    );

    test(
      'debounce behavior - rapid events should be ignored except last',
      () async {
        // Send 5 tasks rapidly
        for (var i = 1; i <= 5; i++) {
          bloc.add(PerformTaskEvent(i));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }

        // Wait for debounce to complete
        await Future<void>.delayed(const Duration(milliseconds: 2500));

        // Should have only 1 task (the last one)
        expect(bloc.state.tasks.length, 1);
        expect(bloc.state.tasks.first.id, 5);
        expect(bloc.state.totalTasksPerformed, 1);
      },
    );
  });
}
