import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TickerEvent extends Equatable {
  TickerEvent([List props = const []]) : super(props);
}

class StartTicker extends TickerEvent {}

class Tick extends TickerEvent {
  final int tickCount;

  Tick(this.tickCount) : super([tickCount]);

  @override
  String toString() => 'Tick $tickCount';
}
