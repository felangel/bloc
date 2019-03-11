// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_todos/blocs/filtered_todos/filtered_todos.dart';
import 'package:flutter_todos/blocs/todos/todos.dart';
import 'package:flutter_todos/models/models.dart';

class FilteredTodosBloc extends Bloc<FilteredTodosEvent, FilteredTodosState> {
  final TodosBloc todosBloc;
  StreamSubscription todosSubscription;

  FilteredTodosBloc({@required this.todosBloc}) {
    todosSubscription = todosBloc.state.listen((state) {
      if (state is TodosLoaded) {
        dispatch(TodosUpdated((todosBloc.currentState as TodosLoaded).todos));
      }
    });
  }

  @override
  FilteredTodosState get initialState => todosBloc.currentState is TodosLoaded
      ? FilteredTodosState(
          (todosBloc.currentState as TodosLoaded).todos,
          VisibilityFilter.all,
        )
      : FilteredTodosState([], VisibilityFilter.all);

  @override
  Stream<FilteredTodosState> mapEventToState(
    FilteredTodosState currentState,
    FilteredTodosEvent event,
  ) async* {
    if (event is UpdateFilter) {
      yield* _mapUpdateFilterToState(currentState, event);
    } else if (event is TodosUpdated) {
      yield* _mapTodosUpdatedToState(currentState, event);
    }
  }

  Stream<FilteredTodosState> _mapUpdateFilterToState(
    FilteredTodosState currentState,
    UpdateFilter event,
  ) async* {
    if (todosBloc.currentState is TodosLoaded) {
      yield FilteredTodosState(
        _mapTodosToFilteredTodos(
            (todosBloc.currentState as TodosLoaded).todos, event.newFilter),
        event.newFilter,
      );
    }
  }

  Stream<FilteredTodosState> _mapTodosUpdatedToState(
    FilteredTodosState currentState,
    TodosUpdated event,
  ) async* {
    yield FilteredTodosState(
      _mapTodosToFilteredTodos(
        (todosBloc.currentState as TodosLoaded).todos,
        currentState.activeFilter,
      ),
      currentState.activeFilter,
    );
  }

  @override
  void dispose() {
    todosSubscription.cancel();
    super.dispose();
  }

  _mapTodosToFilteredTodos(List<Todo> todos, VisibilityFilter filter) {
    return todos.where((todo) {
      if (filter == VisibilityFilter.all) {
        return true;
      } else if (filter == VisibilityFilter.active) {
        return !todo.complete;
      } else if (filter == VisibilityFilter.completed) {
        return todo.complete;
      }
    }).toList();
  }
}
