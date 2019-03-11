// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:flutter_todos/models/models.dart';

class FilteredTodosState extends Equatable {
  final List<Todo> filteredTodos;
  final VisibilityFilter activeFilter;

  FilteredTodosState(this.filteredTodos, this.activeFilter)
      : super([filteredTodos, activeFilter]);

  @override
  String toString() =>
      'FilteredTodosState { filteredTodos: $filteredTodos, activeFilter: $activeFilter }';
}
