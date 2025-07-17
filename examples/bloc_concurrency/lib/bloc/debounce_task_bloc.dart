part of 'base_task_bloc.dart';

/// Debounce Task BLoC for handling tasks with debounce behavior
class DebounceTaskBloc extends BaseTaskBloc {
  /// Creates an instance of [DebounceTaskBloc].
  DebounceTaskBloc() : super() {
    on<TriggerTaskEvent>(_onTriggerTask);
    on<PerformTaskEvent>(
      _onPerformTask,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 2000))
          .flatMap(mapper),
    );
  }

  void _onTriggerTask(TriggerTaskEvent event, Emitter<TaskState> emit) {
    /// Add a waiting task to the timeline
    final waitingTask = Task(
      id: event.taskId,
      status: TaskStatus.waiting,
      startTime: DateTime.now(),
      statusMessage: 'Waiting for debounce period to complete (2s)',
    );

    final updatedTasks = [...state.tasks, waitingTask];
    emit(
      state.copyWith(
        tasks: updatedTasks,
        totalTasksPerformed: state.totalTasksPerformed + 1,
      ),
    );

    /// Trigger the task after debounce period
    add(PerformTaskEvent(event.taskId));
  }

  Future<void> _onPerformTask(
    PerformTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      if (!isClosed) {
        await simulateTaskExecution(event.taskId, Colors.deepOrange, emit);
      }
    } catch (e) {
      if (!e.toString().contains('Cannot add new events after calling close')) {
        rethrow;
      }
    }
  }
}
