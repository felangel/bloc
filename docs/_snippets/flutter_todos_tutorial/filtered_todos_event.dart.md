```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_todos/models/models.dart';

abstract class FilteredTodosEvent extends Equatable {
  const FilteredTodosEvent();
}

class FilterUpdated extends FilteredTodosEvent {
  final VisibilityFilter filter;

  const FilterUpdated(this.filter);

  @override
  List<Object> get props => [filter];

  @override
  String toString() => 'FilterUpdated { filter: $filter }';
}

class TodosUpdated extends FilteredTodosEvent {
  final List<Todo> todos;

  const TodosUpdated(this.todos);

  @override
  List<Object> get props => [todos];

  @override
  String toString() => 'TodosUpdated { todos: $todos }';
}
```
