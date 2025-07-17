part of 'base_task_bloc.dart';

/// Represents a task with its properties
abstract class TaskEvent extends Equatable {
  /// Creates an instance of [TaskEvent].
  const TaskEvent();
}

/// Represents an event to perform a task
class PerformTaskEvent extends TaskEvent {
  /// Creates an instance of [PerformTaskEvent].
  const PerformTaskEvent(this.taskId);

  /// The unique identifier for the task
  final int taskId;

  @override
  List<Object> get props => [taskId];
}

/// Represents an event to clear the task timeline
class ClearTasksEvent extends TaskEvent {
  /// Creates an instance of [ClearTasksEvent].
  const ClearTasksEvent();

  @override
  List<Object> get props => [];
}

/// Represents an event to update the status of a task
class UpdateTaskStatusEvent extends TaskEvent {
  /// Creates an instance of [UpdateTaskStatusEvent].
  const UpdateTaskStatusEvent(this.taskId, this.status);

  /// The unique identifier for the task
  final int taskId;

  /// The new status of the task
  final TaskStatus status;

  @override
  List<Object> get props => [taskId, status];
}

/// Represents an event to trigger task with UI feedback
class TriggerTaskEvent extends TaskEvent {
  /// Creates an instance of [TriggerTaskEvent].
  const TriggerTaskEvent(this.taskId);

  /// The unique identifier for the task
  final int taskId;

  @override
  List<Object> get props => [taskId];
}
