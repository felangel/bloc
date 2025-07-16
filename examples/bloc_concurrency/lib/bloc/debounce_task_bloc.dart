part of 'base_task_bloc.dart';

/// Debounce Task BLoC for handling tasks with debounce behavior
class DebounceTaskBloc extends BaseTaskBloc {
  /// Creates an instance of [DebounceTaskBloc].
  DebounceTaskBloc() : super() {
    on<PerformTaskEvent>(
      _onPerformTask,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 2000))
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
        await simulateTaskExecution(event.taskId, Colors.deepOrange, emit);
      }
    } catch (e) {
      // Ignore errors if bloc is closed during animation
      if (!e.toString().contains('Cannot add new events after calling close')) {
        rethrow;
      }
    }
  }
}
