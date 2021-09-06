import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_todos/blocs/todos/todos.dart';
import 'package:flutter_todos/models/models.dart';
import 'package:todos_repository_simple/todos_repository_simple.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodosRepositoryFlutter todosRepository;

  TodosBloc({
    @required this.todosRepository,
  }) : super(TodosLoadInProgress()) {
    on<TodosLoaded>(_onTodosLoaded);
    on<TodoAdded>(_onTodoAdded);
    on<TodoUpdated>(_onTodoUpdated);
    on<TodoDeleted>(_onTodoDeleted);
    on<ToggleAll>(_onToggleAll);
    on<ClearCompleted>(_onClearCompleted);
  }

  Future<void> _onTodosLoaded(TodosLoaded event, Emitter emit) async {
    try {
      final todos = await this.todosRepository.loadTodos();
      emit(TodosLoadSuccess(todos.map(Todo.fromEntity).toList()));
    } catch (_) {
      emit(TodosLoadFailure());
    }
  }

  void _onTodoAdded(TodoAdded event, Emitter emit) async {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos = List.from(
        (state as TodosLoadSuccess).todos,
      )..add(event.todo);
      emit(TodosLoadSuccess(updatedTodos));
      await _saveTodos(updatedTodos);
    }
  }

  void _onTodoUpdated(TodoUpdated event, Emitter emit) async {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos =
          (state as TodosLoadSuccess).todos.map((todo) {
        return todo.id == event.todo.id ? event.todo : todo;
      }).toList();
      emit(TodosLoadSuccess(updatedTodos));
      await _saveTodos(updatedTodos);
    }
  }

  void _onTodoDeleted(TodoDeleted event, Emitter emit) async {
    if (state is TodosLoadSuccess) {
      final updatedTodos = (state as TodosLoadSuccess)
          .todos
          .where((todo) => todo.id != event.todo.id)
          .toList();
      emit(TodosLoadSuccess(updatedTodos));
      await _saveTodos(updatedTodos);
    }
  }

  void _onToggleAll(ToggleAll event, Emitter emit) async {
    if (state is TodosLoadSuccess) {
      final allComplete =
          (state as TodosLoadSuccess).todos.every((todo) => todo.complete);
      final List<Todo> updatedTodos = (state as TodosLoadSuccess)
          .todos
          .map((todo) => todo.copyWith(complete: !allComplete))
          .toList();
      emit(TodosLoadSuccess(updatedTodos));
      await _saveTodos(updatedTodos);
    }
  }

  void _onClearCompleted(ClearCompleted event, Emitter emit) async {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos = (state as TodosLoadSuccess)
          .todos
          .where((todo) => !todo.complete)
          .toList();
      emit(TodosLoadSuccess(updatedTodos));
      await _saveTodos(updatedTodos);
    }
  }

  Future _saveTodos(List<Todo> todos) {
    return todosRepository.saveTodos(
      todos.map((todo) => todo.toEntity()).toList(),
    );
  }
}
