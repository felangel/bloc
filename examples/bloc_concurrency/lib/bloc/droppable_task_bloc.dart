part of 'base_task_bloc.dart';

/// Droppable Task BLoC for handling tasks that can be dropped
class DroppableTaskBloc extends BaseTaskBloc {
  /// Creates an instance of [DroppableTaskBloc].
  DroppableTaskBloc() : super() {
    on<TriggerTaskEvent>(_onTriggerTask);
    on<PerformTaskEvent>(_onPerformTask, transformer: droppable());
  }

  void _onTriggerTask(TriggerTaskEvent event, Emitter<TaskState> emit) {
    // Check if any task is already running
    final hasRunningTask = state.tasks.any(
      (task) => task.status == TaskStatus.running,
    );

    if (hasRunningTask) {
      /// Add a dropped task to the timeline
      final droppedTask = Task(
        id: event.taskId,
        status: TaskStatus.dropped,
        startTime: DateTime.now(),
        color: Colors.orange,
        statusMessage: 'Dropped - Another task is running',
      );

      final updatedTasks = [...state.tasks, droppedTask];
      emit(state.copyWith(tasks: updatedTasks));
      return; // Exit early if a task is running
    }

    // Add the actual perform event if no task is running
    emit(state.copyWith(totalTasksPerformed: state.totalTasksPerformed + 1));
    add(PerformTaskEvent(event.taskId));
  }

  Future<void> _onPerformTask(
    PerformTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      if (!isClosed) {
        await simulateTaskExecution(event.taskId, Colors.orange, emit);
      }
    } catch (e) {
      if (!e.toString().contains('Cannot add new events after calling close')) {
        rethrow;
      }
    }
  }
}
