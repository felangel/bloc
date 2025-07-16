import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Task', () {
    group('constructor', () {
      test('creates a Task instance with correct properties', () {
        const task = Task(
          id: 1,
          status: TaskStatus.running,
          duration: Duration(seconds: 30),
          statusMessage: 'Task is running',
        );

        expect(task.id, 1);
        expect(task.status, TaskStatus.running);
        expect(task.duration, const Duration(seconds: 30));
        expect(task.color, Colors.blue);
        expect(task.statusMessage, 'Task is running');
      });
    });
    test('copyWith creates a new instance with updated properties', () {
      const task = Task(
        id: 1,
        status: TaskStatus.running,
        duration: Duration(seconds: 30),
        statusMessage: 'Task is running',
      );

      final updatedTask = task.copyWith(
        id: 2,
        status: TaskStatus.finished,
        duration: const Duration(seconds: 45),
        color: Colors.red,
        statusMessage: 'Task completed',
      );

      expect(updatedTask.id, 2);
      expect(updatedTask.status, TaskStatus.finished);
      expect(updatedTask.duration, const Duration(seconds: 45));
      expect(updatedTask.color, Colors.red);
      expect(updatedTask.statusMessage, 'Task completed');
    });
  });
}
