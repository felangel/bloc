import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc_concurrency_visualizer/timeline/timeline.dart';
import 'package:equatable/equatable.dart';

part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  TimelineBloc({
    required Transformer transformer,
    required double Function() now,
  }) : _now = now,
       _transformer = transformer,
       super(const TimelineState()) {
    on<TimelineTaskQueued>(_onTaskQueued);
    on<_TimelineTaskAdded>(_onTaskAdded, transformer: transformer.create());
    on<TimelineCompleted>((event, emit) => emit(const TimelineState()));
    on<TimelineReset>((event, emit) => emit(const TimelineState()));
  }

  final Transformer _transformer;

  final double Function() _now;

  Future<void> _onTaskQueued(
    TimelineTaskQueued event,
    Emitter<TimelineState> emit,
  ) async {
    final cancel =
        _transformer.isDroppable &&
        state.tasks.values.any((task) => task.isRunning);

    final duration = Duration(seconds: Random().nextInt(1) + 1);
    final now = _now();

    final task = cancel
        ? Task.canceled(start: now, end: now, duration: duration)
        : Task.queued(start: now, duration: duration);

    emit(TimelineState(tasks: {...state.tasks, task.id: task}));
    add(_TimelineTaskAdded(task: task));
  }

  Future<void> _onTaskAdded(
    _TimelineTaskAdded event,
    Emitter<TimelineState> emit,
  ) async {
    emit(
      TimelineState(
        tasks: {
          ...state.tasks.map((id, task) {
            if (id == event.task.id) return MapEntry(id, task.run());
            return MapEntry(
              id,
              _transformer.isRestartable && task.isRunning
                  ? task.cancel(end: _now())
                  : task,
            );
          }),
        },
      ),
    );

    await Future<void>.delayed(event.task.duration);

    if (!state.tasks.containsKey(event.task.id)) return;

    emit(
      TimelineState(
        tasks: {...state.tasks}
          ..update(
            event.task.id,
            (task) => emit.isDone
                ? task.cancel(end: _now())
                : task.finish(end: _now()),
          ),
      ),
    );
  }
}

extension on Transformer {
  bool get isDroppable => this == Transformer.droppable;
  bool get isRestartable => this == Transformer.restartable;

  EventTransformer<_TimelineTaskAdded> create() {
    return switch (this) {
      Transformer.concurrent => concurrent(),
      Transformer.sequential => sequential(),
      Transformer.droppable => droppable(),
      Transformer.restartable => restartable(),
    };
  }
}
