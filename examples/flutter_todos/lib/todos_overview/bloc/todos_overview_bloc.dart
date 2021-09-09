import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

part 'todos_overview_event.dart';
part 'todos_overview_state.dart';

extension EmitterX<S> on Emitter<S> {
  Future<void> onEachEmit<T>(
    Stream<T> stream,
    S Function(T) mapper, {
    S Function(Object?)? onError,
  }) {
    var future = onEach(stream, (T data) => call(mapper(data)));
    if (onError != null) {
      future = future.onError((e, st) => call(onError(e)));
    }

    return future;
  }
}

class TodosOverviewBloc extends Bloc<TodosOverviewEvent, TodosOverviewState> {
  TodosOverviewBloc({
    required TodosRepository todosRepository,
  })  : _todosRepository = todosRepository,
        super(const TodosOverviewState()) {
    on<TodosOverviewSubscriptionRequested>((event, emit) {
      emit(state.copyWith(status: TodosOverviewStatus.loading));

      return emit.onEachEmit<List<Todo>>(
        _todosRepository.getTodos(),
        (todos) => state.copyWith(
          status: TodosOverviewStatus.success,
          todos: todos,
        ),
        onError: (_) => state.copyWith(
          status: TodosOverviewStatus.failure,
        ),
      );
    });

    on<TodosOverviewTodoSaved>((event, emit) async {
      await _todosRepository.saveTodo(event.todo);
    });

    on<TodosOverviewTodoCompletionToggled>((event, emit) async {
      await _todosRepository
          .saveTodo(event.todo.copyWith(completed: event.completed));
    });

    on<TodosOverviewTodoDeleted>((event, emit) async {
      emit(state.copyWith(lastDeletedTodo: event.todo));
      await _todosRepository.deleteTodo(event.todo.id);
    });

    on<TodosOverviewUndoDeletionRequested>((event, emit) async {
      assert(state.lastDeletedTodo != null);

      final todo = state.lastDeletedTodo!;
      emit(state.withoutLastDeletedTodo());
      await _todosRepository.saveTodo(todo);
    });
  }

  final TodosRepository _todosRepository;
}
