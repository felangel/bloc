part of 'base_task_bloc.dart';

/// Sequential Task BLoC for handling tasks one after another
class SequentialTaskBloc extends BaseTaskBloc {
  /// Creates an instance of [SequentialTaskBloc].
  SequentialTaskBloc() : super() {
    on<TriggerTaskEvent>(_onTriggerTask);
    on<PerformTaskEvent>(_onPerformTask, transformer: sequential());
  }

  void _onTriggerTask(TriggerTaskEvent event, Emitter<TaskState> emit) {
    /// Add a waiting task to the timeline
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

    /// Then add the actual perform event
    add(PerformTaskEvent(event.taskId));
  }

  Future<void> _onPerformTask(
    PerformTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      if (!isClosed) {
        await simulateTaskExecution(event.taskId, Colors.blue, emit);
      }
    } catch (e) {
      if (!e.toString().contains('Cannot add new events after calling close')) {
        rethrow;
      }
    }
  }
}
