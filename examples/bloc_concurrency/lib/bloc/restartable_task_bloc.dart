part of 'base_task_bloc.dart';

/// Restartable Task BLoC for handling tasks that can be restarted
class RestartableTaskBloc extends BaseTaskBloc {
  /// Creates an instance of [RestartableTaskBloc].
  RestartableTaskBloc() : super() {
    on<PerformTaskEvent>(_onPerformTask, transformer: restartable());
  }

  Future<void> _onPerformTask(
    PerformTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    // Cancel previous running tasks
    final updatedTasks = state.tasks.map((task) {
      if (task.status == TaskStatus.running) {
        return task.copyWith(status: TaskStatus.cancelled);
      }
      return task;
    }).toList();

    emit(
      state.copyWith(
        tasks: updatedTasks,
        totalTasksPerformed: state.totalTasksPerformed + 1,
      ),
    );

    // Use try-catch to handle potential close errors
    try {
      if (!isClosed) {
        await simulateTaskExecution(event.taskId, Colors.purple, emit);
      }
    } catch (e) {
      // Ignore errors if bloc is closed during animation
      if (!e.toString().contains('Cannot add new events after calling close')) {
        rethrow;
      }
    }
  }
}
