import 'package:flutter_todos/todos_overview/models/todos_view_filter.dart';
import 'package:todos_repository/todos_repository.dart';

enum TodosOverviewStatus { initial, loading, success, failure }

class TodosOverviewState {
  const TodosOverviewState({
    required this.todos,
    this.status = TodosOverviewStatus.initial,
    this.filter = TodosViewFilter.all,
    this.lastDeletedTodo,
  });

  final TodosOverviewStatus status;
  final List<Todo> todos;
  final TodosViewFilter filter;
  final Todo? lastDeletedTodo;

  TodosOverviewState copyWith({
    TodosOverviewStatus? status,
    List<Todo>? todos,
    TodosViewFilter? filter,
    Todo? lastDeletedTodo,
  }) =>
      TodosOverviewState(
        status: status ?? this.status,
        todos: todos ?? this.todos,
        filter: filter ?? this.filter,
        lastDeletedTodo: lastDeletedTodo ?? this.lastDeletedTodo,
      );

  Iterable<Todo> get filteredTodos => filter.applyAll(todos);
}
