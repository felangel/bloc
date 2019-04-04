import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TickerState extends Equatable {
  TickerState([List props = const []]) : super(props);
}

class Initial extends TickerState {}

class Update extends TickerState {
  final int count;

  Update(this.count) : super([count]);
}
