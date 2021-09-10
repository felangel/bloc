import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

part 'todos_overview_event.dart';
part 'todos_overview_state.dart';

class TodosOverviewBloc extends Bloc<TodosOverviewEvent, TodosOverviewState> {
  TodosOverviewBloc({
    required TodosRepository todosRepository,
  })  : _todosRepository = todosRepository,
        super(const TodosOverviewState()) {
    on<TodosOverviewSubscriptionRequested>((event, emit) async {
      emit(state.copyWith(status: TodosOverviewStatus.loading));

      await emit.forEach<List<Todo>>(
        _todosRepository.getTodos(),
        onData: (todos) => state.copyWith(
          status: TodosOverviewStatus.success,
          todos: todos,
        ),
        onError: (e, st) => state.copyWith(
          status: TodosOverviewStatus.failure,
        ),
      );
    });

    on<TodosOverviewTodoSaved>((event, emit) async {
      await _todosRepository.saveTodo(event.todo);
    });

    on<TodosOverviewTodoCompletionToggled>((event, emit) async {
      final newTodo = event.todo.copyWith(isCompleted: event.isCompleted);
      await _todosRepository.saveTodo(newTodo);
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

    on<TodosOverviewFilterChanged>((event, emit) {
      emit(state.copyWith(filter: event.filter));
    });

    on<TodosOverviewToggleAllRequested>((event, emit) async {
      final areAllCompleted = state.todos.every((todo) => todo.isCompleted);
      await _todosRepository.completeAll(!areAllCompleted);
    });

    on<TodosOverviewClearCompletedRequested>((event, emit) async {
      await _todosRepository.clearCompleted();
    });
  }

  final TodosRepository _todosRepository;
}
