import 'package:flutter/material.dart';

/// Represents the status of a task in the task scheduler.
enum TaskStatus {
  /// The task is waiting to be executed.
  running,

  /// The task has been completed successfully.
  finished,

  /// The task has been cancelled before completion.
  cancelled,

  /// The task has been dropped, meaning it was not executed.
  dropped,

  /// The task is currently waiting for execution.
  waiting,
}

/// Represents a task in the task scheduler.
class Task {
  /// Creates an instance of [Task].
  const Task({
    required this.id,
    required this.status,
    this.startTime,
    this.duration,
    this.color = Colors.blue,
    this.statusMessage,
  });

  /// The unique identifier for the task.
  final int id;

  /// The current status of the task.
  final TaskStatus status;

  /// The time when the task started executing.
  final DateTime? startTime;

  /// The duration for which the task is expected to run.
  final Duration? duration;

  /// The color associated with the task, used for UI representation.
  final Color color;

  /// An optional message providing additional information.
  final String? statusMessage;

  /// Creates a copy of the task with updated properties.
  Task copyWith({
    int? id,
    TaskStatus? status,
    DateTime? startTime,
    Duration? duration,
    Color? color,
    String? statusMessage,
  }) {
    return Task(
      id: id ?? this.id,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      color: color ?? this.color,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
