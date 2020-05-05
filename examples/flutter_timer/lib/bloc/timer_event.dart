part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerRunStarted extends TimerEvent {
  final int duration;

  const TimerRunStarted({@required this.duration});

  @override
  String toString() => "Start { duration: $duration }";
}

class TimerRunPaused extends TimerEvent {}

class TimerRunResumed extends TimerEvent {}

class TimerRunReset extends TimerEvent {}

class TimerTicked extends TimerEvent {
  final int duration;

  const TimerTicked({@required this.duration});

  @override
  List<Object> get props => [duration];

  @override
  String toString() => "Tick { duration: $duration }";
}
