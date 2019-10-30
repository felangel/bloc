import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => const <Object>[];
}

class Increment extends HomeEvent {
  const Increment();
}
