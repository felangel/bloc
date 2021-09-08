import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todos_api/todos_api.dart';

/// {@template local_storage_todos_api}
/// A Flutter implementation of the [TodosApi] that uses local storage.
/// {@endtemplate}
class LocalStorageTodosApi extends TodosApi {
  /// {@macro local_storage_todos_api}
  LocalStorageTodosApi(SharedPreferences plugin) : _plugin = plugin {
    _init();
  }

  final SharedPreferences _plugin;
  final _todoStreamController = BehaviorSubject<List<Todo>>.seeded(const []);

  /// The key used for storing the todos locally.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kTodosCollectionKey = 'todos';

  String? _getValue(String key) => _plugin.getString(key);
  Future<void> _setValue(String key, String value) =>
      _plugin.setString(key, value);

  Future<void> _init() async {
    final todosJson = _getValue(kTodosCollectionKey);
    if (todosJson != null) {
      final todos = List<Map>.from(json.decode(todosJson) as List)
          .map((jsonMap) => Todo.fromJson(Map<String, dynamic>.from(jsonMap)))
          .toList();
      _todoStreamController.add(todos);
    }
  }

  @override
  Stream<List<Todo>> getTodos() => _todoStreamController.stream;

  @override
  Future<void> saveTodo(Todo todo) {
    final todos = _todoStreamController.value;
    final todoIndex = todos.indexWhere((t) => t.id == todo.id);
    if (todoIndex >= 0) {
      todos[todoIndex] = todo;
    } else {
      todos.add(todo);
    }

    _todoStreamController.add(todos);
    return _setValue(kTodosCollectionKey, json.encode(todos));
  }

  @override
  Future<void> deleteTodo(String id) async {
    final todos = _todoStreamController.value;
    final todoIndex = todos.indexWhere((t) => t.id == id);
    if (todoIndex == -1) {
      throw TodoNotFoundException();
    } else {
      todos.removeAt(todoIndex);
      _todoStreamController.add(todos);
      return _setValue(kTodosCollectionKey, json.encode(todos));
    }
  }

  @override
  Future<int> deleteCompleted() async {
    final todos = _todoStreamController.value;
    final completedTodos = todos.where((t) => t.completed).toList();
    todos.removeWhere((t) => t.completed);
    _todoStreamController.add(todos);
    await _setValue(kTodosCollectionKey, json.encode(todos));
    return completedTodos.length;
  }
}
