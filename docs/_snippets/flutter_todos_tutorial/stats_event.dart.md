```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_todos/models/models.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();
}

class StatsUpdated extends StatsEvent {
  final List<Todo> todos;

  const StatsUpdated(this.todos);

  @override
  List<Object> get props => [todos];

  @override
  String toString() => 'StatsUpdated { todos: $todos }';
}
```
