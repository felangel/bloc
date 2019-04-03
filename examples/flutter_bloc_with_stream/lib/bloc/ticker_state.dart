import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TickerState extends Equatable {
  TickerState([List props = const []]) : super(props);
}

class InitialTickerState extends TickerState {}

class TickUpdate extends TickerState {
  final int count;

  TickUpdate(this.count) : super([count]);
}
