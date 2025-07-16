part of 'base_task_bloc.dart';

/// Concurrent Task BLoC for handling tasks concurrently
class ConcurrentTaskBloc extends BaseTaskBloc {
  /// Creates an instance of [ConcurrentTaskBloc].
  ConcurrentTaskBloc() : super() {
    on<PerformTaskEvent>(_onPerformTask, transformer: concurrent());
  }

  Future<void> _onPerformTask(
    PerformTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(totalTasksPerformed: state.totalTasksPerformed + 1));

    // Use try-catch to handle potential close errors
    try {
      if (!isClosed) {
        await simulateTaskExecution(event.taskId, Colors.green, emit);
      }
    } catch (e) {
      // Ignore errors if bloc is closed during animation
      if (!e.toString().contains('Cannot add new events after calling close')) {
        rethrow;
      }
    }
  }
}
