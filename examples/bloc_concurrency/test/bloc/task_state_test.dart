import 'package:bloc_concurrency_demo/bloc/base_task_bloc.dart';
import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const taskId = 1;
  group('TaskState', () {
    test('supports value comparisons', () {
      const taskState1 = TaskState(
        tasks: [],
        totalTasksPerformed: 0,
      );
      const taskState2 = TaskState(
        tasks: [],
        totalTasksPerformed: 0,
      );
      expect(taskState1, taskState2);
    });

    test('returns completed tasks', () {
      const taskState = TaskState(
        tasks: [
          Task(id: taskId, status: TaskStatus.finished),
          Task(id: 2, status: TaskStatus.running),
        ],
        totalTasksPerformed: 1,
      );
      expect(taskState.completedTasks.length, 1);
      expect(taskState.completedTasks.first.id, taskId);
    });
  });
}
