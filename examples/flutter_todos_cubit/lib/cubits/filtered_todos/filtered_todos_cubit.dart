import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_todos_cubit/cubits/filtered_todos/filtered_todos.dart';
import 'package:flutter_todos_cubit/cubits/todos/todos.dart';
import 'package:flutter_todos_cubit/models/models.dart';

class FilteredTodosCubit extends Cubit<FilteredTodosState> {
  final TodosCubit todosCubit;
  StreamSubscription todosSubscription;

  FilteredTodosCubit({@required this.todosCubit})
      : super(
          todosCubit.state is TodosLoadSuccess
              ? FilteredTodosLoadSuccess(
                  (todosCubit.state as TodosLoadSuccess).todos,
                  VisibilityFilter.all,
                )
              : FilteredTodosLoadInProgress(),
        ) {
    todosSubscription = todosCubit.listen((state) {
      if (state is TodosLoadSuccess) {
        todosUpdated((todosCubit.state as TodosLoadSuccess).todos);
      }
    });
  }

  Future<void> filterUpdated(final VisibilityFilter filter) async {
    if (todosCubit.state is TodosLoadSuccess) {
      emit(FilteredTodosLoadSuccess(
        _mapTodosToFilteredTodos(
          (todosCubit.state as TodosLoadSuccess).todos,
          filter,
        ),
        filter,
      ));
    }
  }

  Future<void> todosUpdated(final List<Todo> todos) async {
    final visibilityFilter = state is FilteredTodosLoadSuccess
        ? (state as FilteredTodosLoadSuccess).activeFilter
        : VisibilityFilter.all;
    emit(FilteredTodosLoadSuccess(
      _mapTodosToFilteredTodos(
        (todosCubit.state as TodosLoadSuccess).todos,
        visibilityFilter,
      ),
      visibilityFilter,
    ));
  }

  List<Todo> _mapTodosToFilteredTodos(
      List<Todo> todos, VisibilityFilter filter) {
    return todos.where((todo) {
      if (filter == VisibilityFilter.all) {
        return true;
      } else if (filter == VisibilityFilter.active) {
        return !todo.complete;
      } else {
        return todo.complete;
      }
    }).toList();
  }

  @override
  Future<void> close() {
    todosSubscription.cancel();
    return super.close();
  }
}
