import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:flutter_firestore_todos/blocs/filtered_todos/filtered_todos.dart';
import 'package:flutter_firestore_todos/blocs/todos/todos.dart';
import 'package:flutter_firestore_todos/models/models.dart';

class FilteredTodosBloc extends Bloc<FilteredTodosEvent, FilteredTodosState> {
  final TodosBloc _todosBloc;
  late StreamSubscription _todosSubscription;

  FilteredTodosBloc({required TodosBloc todosBloc})
      : _todosBloc = todosBloc,
        super(
          todosBloc.state is TodosLoaded
              ? FilteredTodosLoaded(
                  (todosBloc.state as TodosLoaded).todos,
                  VisibilityFilter.all,
                )
              : FilteredTodosLoading(),
        ) {
    on<UpdateFilter>(_onUpdateFilter);
    on<UpdateTodos>(_onUpdateTodos);
    _todosSubscription = todosBloc.stream.listen((state) {
      if (state is TodosLoaded) add(UpdateTodos(state.todos));
    });
  }

  void _onUpdateFilter(UpdateFilter event, Emitter<FilteredTodosState> emit) {
    final state = _todosBloc.state;
    if (state is TodosLoaded) {
      emit(FilteredTodosLoaded(
        _mapTodosToFilteredTodos(state.todos, event.filter),
        event.filter,
      ));
    }
  }

  void _onUpdateTodos(UpdateTodos event, Emitter<FilteredTodosState> emit) {
    final state = this.state;
    final visibilityFilter = state is FilteredTodosLoaded
        ? state.activeFilter
        : VisibilityFilter.all;
    emit(
      FilteredTodosLoaded(
        _mapTodosToFilteredTodos(
          (_todosBloc.state as TodosLoaded).todos,
          visibilityFilter,
        ),
        visibilityFilter,
      ),
    );
  }

  List<Todo> _mapTodosToFilteredTodos(
    List<Todo> todos,
    VisibilityFilter filter,
  ) {
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
    _todosSubscription.cancel();
    return super.close();
  }
}
