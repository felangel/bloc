part of 'base_task_bloc.dart';

/// Droppable Task BLoC for handling tasks that can be dropped
class DroppableTaskBloc extends BaseTaskBloc {
  /// Creates an instance of [DroppableTaskBloc].
  DroppableTaskBloc() : super() {
    on<PerformTaskEvent>(_onPerformTask, transformer: droppable());
  }
  Future<void> _onPerformTask(
    PerformTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    // Check if any task is already running
    final hasRunningTask = state.tasks.any(
      (task) => task.status == TaskStatus.running,
    );

    if (hasRunningTask) {
      // Add dropped task to show it was dropped
      final droppedTask = Task(
        id: event.taskId,
        status: TaskStatus.dropped,
        startTime: DateTime.now(),
        color: Colors.orange,
        statusMessage: 'Dropped - Another task is running',
      );

      final updatedTasks = [...state.tasks, droppedTask];
      emit(state.copyWith(tasks: updatedTasks));
      return;
    }

    emit(state.copyWith(totalTasksPerformed: state.totalTasksPerformed + 1));
    // Use try-catch to handle potential close errors
    try {
      if (!isClosed) {
        await simulateTaskExecution(event.taskId, Colors.orange, emit);
      }
    } catch (e) {
      // Ignore errors if bloc is closed during animation
      if (!e.toString().contains('Cannot add new events after calling close')) {
        rethrow;
      }
    }
  }
}
