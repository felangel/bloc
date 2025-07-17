import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const taskId = 1;
  group('Task Event', () {
    group('PerformTaskEvent', () {
      test('supports value comparisons', () {
        expect(const PerformTaskEvent(taskId), const PerformTaskEvent(taskId));
      });
    });
    group('ClearTasksEvent', () {
      test('supports value comparisons', () {
        expect(const ClearTasksEvent(), const ClearTasksEvent());
      });
    });
    group('UpdateTaskStatusEvent', () {
      test('supports value comparisons', () {
        expect(
          const UpdateTaskStatusEvent(taskId, TaskStatus.finished),
          const UpdateTaskStatusEvent(taskId, TaskStatus.finished),
        );
      });
    });
    group('TriggerTaskEvent', () {
      test('supports value comparisons', () {
        expect(
          const TriggerTaskEvent(taskId),
          const TriggerTaskEvent(taskId),
        );
      });
    });
  });
}
