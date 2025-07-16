part of 'base_task_bloc.dart';

/// Represents the state of the task BLoC
class TaskState extends Equatable {
  /// Creates an instance of [TaskState].
  const TaskState({
    required this.tasks,
    required this.totalTasksPerformed,
  });

  /// The list of tasks in the current state
  final List<Task> tasks;

  /// The total number of tasks that have been performed
  final int totalTasksPerformed;

  /// Returns the list of tasks that are currently running
  List<Task> get completedTasks =>
      tasks.where((task) => task.status == TaskStatus.finished).toList();

  /// Returns the list of tasks that have been dropped
  List<Task> get runningTasks =>
      tasks.where((task) => task.status == TaskStatus.running).toList();

  /// Returns the list of tasks that have been dropped
  List<Task> get cancelledTasks =>
      tasks.where((task) => task.status == TaskStatus.cancelled).toList();

  /// Returns the list of tasks that have been dropped
  TaskState copyWith({
    List<Task>? tasks,
    int? totalTasksPerformed,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      totalTasksPerformed: totalTasksPerformed ?? this.totalTasksPerformed,
    );
  }

  @override
  List<Object> get props => [
    tasks,
    totalTasksPerformed,
  ];
}
