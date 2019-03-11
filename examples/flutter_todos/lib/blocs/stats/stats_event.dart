import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_todos/models/models.dart';

@immutable
abstract class StatsEvent extends Equatable {
  StatsEvent([List props = const []]) : super(props);
}

class UpdateStats extends StatsEvent {
  final List<Todo> todos;

  UpdateStats(this.todos) : super([todos]);

  @override
  String toString() => 'UpdateStats { todos: $todos }';
}
