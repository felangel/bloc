part of 'base_task_bloc.dart';

/// Throttle Task BLoC for handling tasks with throttle behavior
class ThrottleTaskBloc extends BaseTaskBloc {
  /// Creates an instance of [ThrottleTaskBloc].
  ThrottleTaskBloc() : super() {
    on<PerformTaskEvent>(
      _onPerformTask,
      transformer: (events, mapper) => events
          .throttleTime(const Duration(milliseconds: 1000))
          .flatMap(mapper),
    );
  }

  Future<void> _onPerformTask(
    PerformTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(totalTasksPerformed: state.totalTasksPerformed + 1));

    // Use try-catch to handle potential close errors
    try {
      if (!isClosed) {
        await simulateTaskExecution(event.taskId, Colors.indigo, emit);
      }
    } catch (e) {
      // Ignore errors if bloc is closed during animation
      if (!e.toString().contains('Cannot add new events after calling close')) {
        rethrow;
      }
    }
  }
}
