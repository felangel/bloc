import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_todos/blocs/todos/todos.dart';
import 'package:flutter_todos/models/models.dart';
import 'package:todos_repository_simple/todos_repository_simple.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodosRepositoryFlutter todosRepository;

  TodosBloc({@required this.todosRepository});

  @override
  TodosState get initialState => TodosLoading();

  @override
  Stream<TodosState> mapEventToState(
    TodosState currentState,
    TodosEvent event,
  ) async* {
    if (event is LoadTodos) {
      yield* _mapLoadTodosToState();
    } else if (event is AddTodo) {
      yield* _mapAddTodoToState(currentState, event);
    } else if (event is UpdateTodo) {
      yield* _mapUpdateTodoToState(currentState, event);
    } else if (event is DeleteTodo) {
      yield* _mapDeleteTodoToState(currentState, event);
    } else if (event is ToggleAll) {
      yield* _mapToggleAllToState(currentState);
    } else if (event is ClearCompleted) {
      yield* _mapClearCompletedToState(currentState);
    }
  }

  Stream<TodosState> _mapLoadTodosToState() async* {
    try {
      final todos = await this.todosRepository.loadTodos();
      yield TodosLoaded(
        todos.map(Todo.fromEntity).toList(),
      );
    } catch (_) {
      yield TodosNotLoaded();
    }
  }

  Stream<TodosState> _mapAddTodoToState(
    TodosState currentState,
    AddTodo event,
  ) async* {
    if (currentState is TodosLoaded) {
      final List<Todo> updatedTodos = List.from(currentState.todos)
        ..add(event.todo);
      yield TodosLoaded(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapUpdateTodoToState(
    TodosState currentState,
    UpdateTodo event,
  ) async* {
    if (currentState is TodosLoaded) {
      final List<Todo> updatedTodos = currentState.todos.map((todo) {
        return todo.id == event.updatedTodo.id ? event.updatedTodo : todo;
      }).toList();
      yield TodosLoaded(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapDeleteTodoToState(
    TodosState currentState,
    DeleteTodo event,
  ) async* {
    if (currentState is TodosLoaded) {
      final updatedTodos =
          currentState.todos.where((todo) => todo.id != event.todo.id).toList();
      yield TodosLoaded(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapToggleAllToState(TodosState currentState) async* {
    if (currentState is TodosLoaded) {
      final allComplete = currentState.todos.every((todo) => todo.complete);
      final List<Todo> updatedTodos = currentState.todos
          .map((todo) => todo.copyWith(complete: !allComplete))
          .toList();
      yield TodosLoaded(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapClearCompletedToState(TodosState currentState) async* {
    if (currentState is TodosLoaded) {
      final List<Todo> updatedTodos =
          currentState.todos.where((todo) => !todo.complete).toList();
      yield TodosLoaded(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Future _saveTodos(List<Todo> todos) {
    return todosRepository.saveTodos(
      todos.map((todo) => todo.toEntity()).toList(),
    );
  }
}
