import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class Start extends TimerEvent {
  final int duration;

  const Start({@required this.duration});

  @override
  String toString() => "Start { duration: $duration }";
}

class Pause extends TimerEvent {}

class Resume extends TimerEvent {}

class Reset extends TimerEvent {}

class Tick extends TimerEvent {
  final int duration;

  const Tick({@required this.duration});

  @override
  List<Object> get props => [duration];

  @override
  String toString() => "Tick { duration: $duration }";
}
