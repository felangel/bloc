part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  final int duration;

  const TimerState(this.duration);

  @override
  List<Object> get props => [duration];
}

class TimerInitial extends TimerState {
  const TimerInitial(int duration) : super(duration);

  @override
  String toString() => 'Ready { duration: $duration }';
}

class TimerRunningPaused extends TimerState {
  const TimerRunningPaused(int duration) : super(duration);

  @override
  String toString() => 'Paused { duration: $duration }';
}

class TimerRunningInProgress extends TimerState {
  const TimerRunningInProgress(int duration) : super(duration);

  @override
  String toString() => 'Running { duration: $duration }';
}

class TimerRunningFinished extends TimerState {
  const TimerRunningFinished() : super(0);
}
