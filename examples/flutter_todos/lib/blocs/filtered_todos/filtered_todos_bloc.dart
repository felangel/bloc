import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_todos/blocs/filtered_todos/filtered_todos.dart';
import 'package:flutter_todos/blocs/todos/todos.dart';
import 'package:flutter_todos/models/models.dart';

class FilteredTodosBloc extends Bloc<FilteredTodosEvent, FilteredTodosState> {
  final TodosBloc todosBloc;
  StreamSubscription todosSubscription;

  FilteredTodosBloc({
    @required this.todosBloc,
  }) : super(
          todosBloc.state is TodosLoadSuccess
              ? FilteredTodosLoadSuccess(
                  (todosBloc.state as TodosLoadSuccess).todos,
                  VisibilityFilter.all,
                )
              : FilteredTodosLoadInProgress(),
        ) {
    todosSubscription = todosBloc.stream.listen((state) {
      if (state is TodosLoadSuccess) {
        add(TodosUpdated((todosBloc.state as TodosLoadSuccess).todos));
      }
    });

    on<FilterUpdated>(_onFilterUpdated);
    on<TodosUpdated>(_onTodosUpdated);
  }

  void _onFilterUpdated(FilterUpdated event, Emitter emit) {
    if (todosBloc.state is TodosLoadSuccess) {
      emit(
        FilteredTodosLoadSuccess(
          _mapTodosToFilteredTodos(
            (todosBloc.state as TodosLoadSuccess).todos,
            event.filter,
          ),
          event.filter,
        ),
      );
    }
  }

  void _onTodosUpdated(TodosUpdated event, Emitter emit) {
    final visibilityFilter = state is FilteredTodosLoadSuccess
        ? (state as FilteredTodosLoadSuccess).activeFilter
        : VisibilityFilter.all;
    emit(
      FilteredTodosLoadSuccess(
        _mapTodosToFilteredTodos(
          (todosBloc.state as TodosLoadSuccess).todos,
          visibilityFilter,
        ),
        visibilityFilter,
      ),
    );
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
