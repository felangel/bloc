import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/bootstrap.dart';
import 'package:flutter_todos/todos_overview/riverpod/todos_overview_state.dart';
import 'package:flutter_todos/todos_overview/models/todos_view_filter.dart';
import 'package:todos_repository/todos_repository.dart';

final todosOverviewNotifierProvider =
    StateNotifierProvider<TodosOverviewNotifier, TodosOverviewState>(
  (ref) => TodosOverviewNotifier(ref.read(todosRepositoryProvider)),
);

class TodosOverviewNotifier extends StateNotifier<TodosOverviewState> {
  TodosOverviewNotifier(this._todosRepository)
      : super(const TodosOverviewState(todos: [])) {
    _fetchTodos();
  }

  final TodosRepository _todosRepository;

  Future<void> _fetchTodos() async {
    state = state.copyWith(status: TodosOverviewStatus.loading);
    try {
      final todos = await _todosRepository.getTodos().first;
      state = state.copyWith(
        status: TodosOverviewStatus.success,
        todos: todos,
      );
    } catch (error) {
      state = state.copyWith(status: TodosOverviewStatus.failure);
    }
  }

  void fetchTodos() => _fetchTodos();

  // ignore: avoid_positional_boolean_parameters
  Future<void> toggleCompletion(Todo todo, bool isCompleted) async {
    final newTodo = todo.copyWith(isCompleted: isCompleted);
    await _todosRepository.saveTodo(newTodo);
    await _fetchTodos();
  }

  Future<void> deleteTodo(Todo todo) async {
    state = state.copyWith(lastDeletedTodo: todo);
    await _todosRepository.deleteTodo(todo.id);
    await _fetchTodos();
  }

  Future<void> undoDeletion() async {
    final todo = state.lastDeletedTodo;
    if (todo != null) {
      await _todosRepository.saveTodo(todo);
      state = state.copyWith();
      await _fetchTodos();
    }
  }

  void changeFilter(TodosViewFilter filter) =>
      state = state.copyWith(filter: filter);

  Future<void> toggleAll() async {
    final areAllCompleted = state.todos.every((todo) => todo.isCompleted);
    final newStatus = !areAllCompleted;
    for (final todo in state.todos) {
      await _todosRepository.saveTodo(todo.copyWith(isCompleted: newStatus));
    }
    await _fetchTodos();
  }

  Future<void> clearCompleted() async {
    await _todosRepository.clearCompleted();
    await _fetchTodos();
  }
}
