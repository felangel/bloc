import 'package:equatable/equatable.dart';

abstract class TickerEvent extends Equatable {
  const TickerEvent();

  @override
  List<Object> get props => [];
}

class StartTicker extends TickerEvent {}

class Tick extends TickerEvent {
  final int tickCount;

  const Tick(this.tickCount);

  @override
  List<Object> get props => [tickCount];

  @override
  String toString() => 'Tick $tickCount';
}
