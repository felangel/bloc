part of 'base_task_bloc.dart';

/// Throttle Task BLoC for handling tasks with throttle behavior
class ThrottleTaskBloc extends BaseTaskBloc {
  /// Creates an instance of [ThrottleTaskBloc].
  ThrottleTaskBloc() : super() {
    on<TriggerTaskEvent>(_onTriggerTask);
    on<PerformTaskEvent>(
      _onPerformTask,
      transformer: (events, mapper) => events
          .throttleTime(const Duration(milliseconds: 1000))
          .flatMap(mapper),
    );
  }
  DateTime? _lastProcessedTime;

  void _onTriggerTask(TriggerTaskEvent event, Emitter<TaskState> emit) {
    final now = DateTime.now();

    // Check if we're still in throttle window
    if (_lastProcessedTime != null &&
        now.difference(_lastProcessedTime!).inMilliseconds < 1000) {
      /// Show dropped task during throttle window
      final droppedTask = Task(
        id: event.taskId,
        status: TaskStatus.dropped,
        startTime: now,
        color: Colors.indigo,
        statusMessage: 'Dropped - Within throttle window (1s)',
      );

      final updatedTasks = [...state.tasks, droppedTask];
      emit(state.copyWith(tasks: updatedTasks));
      return;

      /// Exit early if within throttle window
    }

    // Update last processed time and increment counter
    _lastProcessedTime = now;
    emit(state.copyWith(totalTasksPerformed: state.totalTasksPerformed + 1));

    /// Add a waiting task to the timeline
    add(PerformTaskEvent(event.taskId));
  }

  Future<void> _onPerformTask(
    PerformTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      if (!isClosed) {
        await simulateTaskExecution(event.taskId, Colors.indigo, emit);
      }
    } catch (e) {
      if (!e.toString().contains('Cannot add new events after calling close')) {
        rethrow;
      }
    }
  }
}
