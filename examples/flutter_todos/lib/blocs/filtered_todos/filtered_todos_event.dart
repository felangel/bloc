// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:equatable/equatable.dart';

import 'package:flutter_todos/models/models.dart';

abstract class FilteredTodosEvent extends Equatable {
  FilteredTodosEvent([List props = const []]) : super(props);
}

class UpdateFilter extends FilteredTodosEvent {
  final VisibilityFilter newFilter;

  UpdateFilter(this.newFilter) : super([newFilter]);

  @override
  String toString() => 'UpdateFilter { newFilter: $newFilter }';
}

class TodosUpdated extends FilteredTodosEvent {
  final List<Todo> todos;

  TodosUpdated(this.todos) : super([todos]);

  @override
  String toString() => 'TodosUpdated { todos: $todos }';
}
