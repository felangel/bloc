import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ==========================================================================
  //  THROTTLE BLOC TESTS
  // ==========================================================================  group('ThrottleTaskBloc', () {

  group('ThrottleTaskBloc', () {
    late ThrottleTaskBloc bloc;

    setUp(() {
      bloc = ThrottleTaskBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('should throttle events and process first one immediately', () async {
      // Send multiple tasks quickly
      bloc
        ..add(const PerformTaskEvent(1))
        ..add(const PerformTaskEvent(2))
        ..add(const PerformTaskEvent(3));

      // Wait for throttle period
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Should have only 1 task (the first one)
      expect(bloc.state.tasks.length, 1);
      expect(bloc.state.tasks.first.id, 1);
      expect(bloc.state.tasks.first.color, Colors.indigo);
      expect(bloc.state.totalTasksPerformed, 1);
    });

    blocTest<ThrottleTaskBloc, TaskState>(
      'should process events separated by throttle duration',
      build: ThrottleTaskBloc.new,
      act: (bloc) async {
        bloc.add(const PerformTaskEvent(1));
        await Future<void>.delayed(const Duration(milliseconds: 1100));
        bloc.add(const PerformTaskEvent(2));
      },
      wait: const Duration(seconds: 3),
      verify: (bloc) {
        expect(bloc.state.totalTasksPerformed, 2);
        expect(bloc.state.tasks.length, 2);
        expect(
          bloc.state.tasks.every((task) => task.color == Colors.indigo),
          true,
        );
      },
    );

    test('throttle behavior - first event processed, others ignored', () async {
      // Send 5 tasks rapidly
      for (var i = 1; i <= 5; i++) {
        bloc.add(PerformTaskEvent(i));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }

      // Wait for throttle period
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Should have only 1 task (the first one)
      expect(bloc.state.tasks.length, 1);
      expect(bloc.state.tasks.first.id, 1);
      expect(bloc.state.totalTasksPerformed, 1);
    });
  });
}
