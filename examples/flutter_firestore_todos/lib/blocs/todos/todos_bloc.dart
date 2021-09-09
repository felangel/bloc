import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_firestore_todos/blocs/todos/todos.dart';
import 'package:todos_repository/todos_repository.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  TodosBloc({required TodosRepository todosRepository})
      : _todosRepository = todosRepository,
        super(TodosLoading()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<ToggleAll>(_onToggleAll);
    on<ClearCompleted>(_onClearCompleted);
    on<TodosUpdated>(_onTodosUpdated);
  }

  final TodosRepository _todosRepository;

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodosState> emit) {
    return emit.onEach<List<Todo>>(
      _todosRepository.todos(),
      onData: (todos) => add(TodosUpdated(todos)),
    );
  }

  void _onAddTodo(AddTodo event, Emitter<TodosState> emit) {
    _todosRepository.addNewTodo(event.todo);
  }

  void _onUpdateTodo(UpdateTodo event, Emitter<TodosState> emit) {
    _todosRepository.updateTodo(event.updatedTodo);
  }

  void _onDeleteTodo(DeleteTodo event, Emitter<TodosState> emit) {
    _todosRepository.deleteTodo(event.todo);
  }

  void _onToggleAll(ToggleAll event, Emitter<TodosState> emit) {
    final currentState = state;
    if (currentState is TodosLoaded) {
      final allComplete = currentState.todos.every((todo) => todo.complete);
      final List<Todo> updatedTodos = currentState.todos
          .map((todo) => todo.copyWith(complete: !allComplete))
          .toList();
      updatedTodos.forEach((updatedTodo) {
        _todosRepository.updateTodo(updatedTodo);
      });
    }
  }

  void _onClearCompleted(ClearCompleted event, Emitter<TodosState> emit) {
    final currentState = state;
    if (currentState is TodosLoaded) {
      final List<Todo> completedTodos =
          currentState.todos.where((todo) => todo.complete).toList();
      completedTodos.forEach((completedTodo) {
        _todosRepository.deleteTodo(completedTodo);
      });
    }
  }

  void _onTodosUpdated(TodosUpdated event, Emitter<TodosState> emit) {
    emit(TodosLoaded(event.todos));
  }
}
