import 'package:equatable/equatable.dart';

abstract class TickerState extends Equatable {
  const TickerState();

  @override
  List<Object> get props => [];
}

class Initial extends TickerState {}

class Update extends TickerState {
  final int count;

  const Update(this.count);

  @override
  List<Object> get props => [count];
}
