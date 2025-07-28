part of 'timeline_bloc.dart';

sealed class TimelineEvent {
  const TimelineEvent();
}

class TimelineTaskQueued extends TimelineEvent {
  const TimelineTaskQueued();
}

class _TimelineTaskAdded extends TimelineEvent {
  const _TimelineTaskAdded({required this.task});

  final Task task;
}

class TimelineCompleted extends TimelineEvent {
  const TimelineCompleted();
}

class TimelineReset extends TimelineEvent {
  const TimelineReset();
}
