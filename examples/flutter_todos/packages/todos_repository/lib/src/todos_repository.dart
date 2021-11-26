import 'package:todos_api/todos_api.dart';

/// {@template todos_repository}
/// A repository that handles todo related requests.
/// {@endtemplate}
class TodosRepository {
  /// {@macro todos_repository}
  const TodosRepository({
    required TodosApi todosApi,
  }) : _todosApi = todosApi;

  final TodosApi _todosApi;

  /// Provides a [Stream] of all todos.
  Stream<List<Todo>> getTodos() => _todosApi.getTodos();

  /// Saves a [todo].
  ///
  /// If a [todo] with the same id already exists, it will be replaced.
  Future<void> saveTodo(Todo todo) => _todosApi.saveTodo(todo);

  /// Deletes the todo with the given id.
  ///
  /// If no todo with the given id exists, a [TodoNotFoundException] error is
  /// thrown.
  Future<void> deleteTodo(String id) => _todosApi.deleteTodo(id);

  /// Deletes all completed todos.
  ///
  /// Returns the number of deleted todos.
  Future<int> clearCompleted() => _todosApi.clearCompleted();

  /// Sets the `isCompleted` state of all todos to the given value.
  ///
  /// Returns the number of updated todos.
  Future<int> completeAll({required bool isCompleted}) =>
      _todosApi.completeAll(isCompleted: isCompleted);
}
