import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:flutter_firestore_todos/blocs/filtered_todos/filtered_todos.dart';
import 'package:flutter_firestore_todos/blocs/todos/todos.dart';
import 'package:flutter_firestore_todos/models/models.dart';

class FilteredTodosBloc extends Bloc<FilteredTodosEvent, FilteredTodosState> {
  final TodosBloc _todosBloc;
  StreamSubscription _todosSubscription;

  FilteredTodosBloc({@required TodosBloc todosBloc})
      : assert(todosBloc != null),
        _todosBloc = todosBloc {
    _todosSubscription = todosBloc.state.listen((state) {
      if (state is TodosLoaded) {
        dispatch(UpdateTodos((todosBloc.currentState as TodosLoaded).todos));
      }
    });
  }

  @override
  FilteredTodosState get initialState {
    final state = _todosBloc.currentState;
    return state is TodosLoaded
        ? FilteredTodosLoaded(state.todos, VisibilityFilter.all)
        : FilteredTodosLoading();
  }

  @override
  Stream<FilteredTodosState> mapEventToState(FilteredTodosEvent event) async* {
    if (event is UpdateFilter) {
      yield* _mapUpdateFilterToState(event);
    } else if (event is UpdateTodos) {
      yield* _mapTodosUpdatedToState(event);
    }
  }

  Stream<FilteredTodosState> _mapUpdateFilterToState(
    UpdateFilter event,
  ) async* {
    final state = _todosBloc.currentState;
    if (state is TodosLoaded) {
      yield FilteredTodosLoaded(
        _mapTodosToFilteredTodos(state.todos, event.filter),
        event.filter,
      );
    }
  }

  Stream<FilteredTodosState> _mapTodosUpdatedToState(
    UpdateTodos event,
  ) async* {
    final visibilityFilter = currentState is FilteredTodosLoaded
        ? (currentState as FilteredTodosLoaded).activeFilter
        : VisibilityFilter.all;
    yield FilteredTodosLoaded(
      _mapTodosToFilteredTodos(
        (_todosBloc.currentState as TodosLoaded).todos,
        visibilityFilter,
      ),
      visibilityFilter,
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
  void dispose() {
    _todosSubscription?.cancel();
    super.dispose();
  }
}
