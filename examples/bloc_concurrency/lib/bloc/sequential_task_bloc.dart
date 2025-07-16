part of 'base_task_bloc.dart';

/// Sequential Task BLoC for handling tasks one after another
class SequentialTaskBloc extends BaseTaskBloc {
  /// Creates an instance of [SequentialTaskBloc].
  SequentialTaskBloc() : super() {
    on<PerformTaskEvent>(_onPerformTask, transformer: sequential());
  }

  Future<void> _onPerformTask(
    PerformTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    // Add waiting task first
    final waitingTask = Task(
      id: event.taskId,
      status: TaskStatus.waiting,
      startTime: DateTime.now(),
      statusMessage: 'Waiting for previous task to complete',
    );

    final updatedTasks = [...state.tasks, waitingTask];
    emit(
      state.copyWith(
        tasks: updatedTasks,
        totalTasksPerformed: state.totalTasksPerformed + 1,
      ),
    );

    // Use try-catch to handle potential close errors
    try {
      if (!isClosed) {
        await simulateTaskExecution(event.taskId, Colors.blue, emit);
      }
    } catch (e) {
      // Ignore errors if bloc is closed during animation
      if (!e.toString().contains('Cannot add new events after calling close')) {
        rethrow;
      }
    }
  }
}
