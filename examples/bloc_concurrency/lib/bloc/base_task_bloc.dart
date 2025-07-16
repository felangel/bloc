import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc_concurrency_demo/models/task.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

part 'task_event.dart';
part 'task_state.dart';
part 'concurrent_task_bloc.dart';
part 'droppable_task_bloc.dart';
part 'restartable_task_bloc.dart';
part 'debounce_task_bloc.dart';
part 'throttle_task_bloc.dart';
part 'sequential_task_bloc.dart';

/// Base class for all task BLoCs
abstract class BaseTaskBloc extends Bloc<TaskEvent, TaskState> {
  /// Creates an instance of [BaseTaskBloc].
  BaseTaskBloc() : super(const TaskState(tasks: [], totalTasksPerformed: 0)) {
    on<ClearTasksEvent>(_onClearTimeline);
    on<UpdateTaskStatusEvent>(_onUpdateTaskStatus);
  }

  void _onClearTimeline(ClearTasksEvent event, Emitter<TaskState> emit) {
    emit(const TaskState(tasks: [], totalTasksPerformed: 0));
  }

  void _onUpdateTaskStatus(
    UpdateTaskStatusEvent event,
    Emitter<TaskState> emit,
  ) {
    final updatedTasks = state.tasks.map((task) {
      if (task.id == event.taskId) {
        return task.copyWith(status: event.status);
      }
      return task;
    }).toList();

    emit(state.copyWith(tasks: updatedTasks));
  }

  /// Simulates task execution with a delay
  Future<void> simulateTaskExecution(
    int taskId,
    Color taskColor,
    Emitter<TaskState> emit,
  ) async {
    // Add task as running
    final runningTask = Task(
      id: taskId,
      status: TaskStatus.running,
      startTime: DateTime.now(),
      duration: const Duration(seconds: 2),
      color: taskColor,
    );

    final updatedTasks = [...state.tasks];
    final existingIndex = updatedTasks.indexWhere((t) => t.id == taskId);

    if (existingIndex != -1) {
      updatedTasks[existingIndex] = runningTask;
    } else {
      updatedTasks.add(runningTask);
    }

    emit(state.copyWith(tasks: updatedTasks));

    // Simulate work
    await Future<void>.delayed(const Duration(seconds: 2));

    // Check if task still exists and mark as finished
    if (state.tasks.any(
      (t) => t.id == taskId && t.status == TaskStatus.running,
    )) {
      add(UpdateTaskStatusEvent(taskId, TaskStatus.finished));
    }
  }
}
