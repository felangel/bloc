import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_firestore_todos/blocs/todos/todos.dart';
import 'package:todos_repository/todos_repository.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodosRepository todosRepository;
  StreamSubscription todosSubscription;

  TodosBloc({@required this.todosRepository});

  @override
  TodosState get initialState => TodosLoading();

  @override
  Stream<TodosState> mapEventToState(TodosEvent event) async* {
    if (event is LoadTodos) {
      yield* _mapLoadTodosToState();
    } else if (event is AddTodo) {
      yield* _mapAddTodoToState(event);
    } else if (event is UpdateTodo) {
      yield* _mapUpdateTodoToState(event);
    } else if (event is DeleteTodo) {
      yield* _mapDeleteTodoToState(event);
    } else if (event is ToggleAll) {
      yield* _mapToggleAllToState();
    } else if (event is ClearCompleted) {
      yield* _mapClearCompletedToState();
    } else if (event is TodosUpdated) {
      yield* _mapTodosUpdateToState(event);
    }
  }

  Stream<TodosState> _mapLoadTodosToState() async* {
    todosSubscription?.cancel();
    todosSubscription = todosRepository.todos().listen(
      (todos) {
        dispatch(
          TodosUpdated(todos),
        );
      },
    );
  }

  Stream<TodosState> _mapAddTodoToState(AddTodo event) async* {
    todosRepository.addNewTodo(event.todo);
  }

  Stream<TodosState> _mapUpdateTodoToState(UpdateTodo event) async* {
    todosRepository.updateTodo(event.updatedTodo);
  }

  Stream<TodosState> _mapDeleteTodoToState(DeleteTodo event) async* {
    todosRepository.deleteTodo(event.todo);
  }

  Stream<TodosState> _mapToggleAllToState() async* {
    final state = currentState;
    if (state is TodosLoaded) {
      final allComplete = state.todos.every((todo) => todo.complete);
      final List<Todo> updatedTodos = state.todos
          .map((todo) => todo.copyWith(complete: !allComplete))
          .toList();
      yield TodosLoaded(updatedTodos);
    }
  }

  Stream<TodosState> _mapClearCompletedToState() async* {
    final state = currentState;
    if (state is TodosLoaded) {
      final List<Todo> updatedTodos =
          state.todos.where((todo) => !todo.complete).toList();
      yield TodosLoaded(updatedTodos);
    }
  }

  Stream<TodosState> _mapTodosUpdateToState(TodosUpdated event) async* {
    yield TodosLoaded(event.todos);
  }

  @override
  void dispose() {
    todosSubscription?.cancel();
    super.dispose();
  }
}
