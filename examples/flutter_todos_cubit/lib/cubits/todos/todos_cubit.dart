import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_todos_cubit/cubits/todos/todos.dart';
import 'package:flutter_todos_cubit/models/models.dart';
import 'package:todos_repository_simple/todos_repository_simple.dart';

class TodosCubit extends Cubit<TodosState> {
  final TodosRepositoryFlutter todosRepository;

  TodosCubit({@required this.todosRepository}) : super(TodosLoadInProgress());

  Future<void> todosLoaded() async {
    try {
      final todos = await this.todosRepository.loadTodos();
      emit(TodosLoadSuccess(
        todos.map(Todo.fromEntity).toList(),
      ));
    } catch (_) {
        emit(TodosLoadFailure());
    }
  }

  Future<void> todoAdded(final Todo todo) async {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos =
      List.from((state as TodosLoadSuccess).todos)..add(todo);
      emit(TodosLoadSuccess(updatedTodos));
      _saveTodos(updatedTodos);
    }
  }

  Future<void> todoUpdated(final Todo todo) async {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos =
      (state as TodosLoadSuccess).todos.map((_) {
        return _.id == todo.id ? todo : _;
      }).toList();
      emit(TodosLoadSuccess(updatedTodos));
      _saveTodos(updatedTodos);
    }
  }

  Future<void> todoDeleted(final Todo todo) async {
    if (state is TodosLoadSuccess) {
      final updatedTodos = (state as TodosLoadSuccess)
          .todos
          .where((_) => _.id != todo.id)
          .toList();
      emit(TodosLoadSuccess(updatedTodos));
      _saveTodos(updatedTodos);
    }
  }

  Future<void> toggleAll() async {
    if (state is TodosLoadSuccess) {
      final allComplete =
      (state as TodosLoadSuccess).todos.every((todo) => todo.complete);
      final List<Todo> updatedTodos = (state as TodosLoadSuccess)
          .todos
          .map((todo) => todo.copyWith(complete: !allComplete))
          .toList();
      emit(TodosLoadSuccess(updatedTodos));
      _saveTodos(updatedTodos);
    }
  }

  Future<void> clearCompleted() async {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos = (state as TodosLoadSuccess)
          .todos
          .where((todo) => !todo.complete)
          .toList();
      emit(TodosLoadSuccess(updatedTodos));
      _saveTodos(updatedTodos);
    }
  }

  Future _saveTodos(List<Todo> todos) {
    return todosRepository.saveTodos(
      todos.map((todo) => todo.toEntity()).toList(),
    );
  }
}
