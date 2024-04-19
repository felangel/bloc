import 'package:todos_api/todos_api.dart';

// ignore: public_member_api_docs
class ConcreteTodosApi extends TodosApi {
  final List<Todo> _todos = [];

  @override
  Stream<List<Todo>> getTodos() {
    return Stream.value(_todos);
  }

  @override
  Future<void> saveTodo(Todo todo) {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
    } else {
      _todos.add(todo);
    }

    return Future.value();
  }

  @override
  Future<void> deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    return Future.value();
  }

  @override
  Future<int> clearCompleted() {
    final completedCount = _todos.where((t) => t.isCompleted).length;
    _todos.removeWhere((t) => t.isCompleted);
    return Future.value(completedCount);
  }

  @override
  Future<int> completeAll({required bool isCompleted}) {
    final todosToUpdate =
        _todos.where((t) => t.isCompleted != isCompleted).length;
    for (var todo in _todos) {
      todo = todo.copyWith(isCompleted: isCompleted);
    }
    return Future.value(todosToUpdate);
  }
}
