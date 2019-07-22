// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:core';

<<<<<<< HEAD
import 'package:todos_repository/todos_repository.dart';
=======
import 'todo_entity.dart';
>>>>>>> 412891a503583b5b9acc39e16dd5964a156ff7c3

/// A data layer class works with reactive data sources, such as Firebase. This
/// class emits a Stream of TodoEntities. The data layer of the app.
///
/// How and where it stores the entities should defined in a concrete
/// implementation, such as firebase_repository_flutter.
///
/// The domain layer should depend on this abstract class, and each app can
/// inject the correct implementation depending on the environment, such as
/// web or Flutter.
abstract class TodosRepository {
<<<<<<< HEAD
  Future<void> addNewTodo(Todo todo);

  Future<void> deleteTodo(Todo todo);

  Stream<List<Todo>> todos();

  Future<void> updateTodo(Todo todo);
=======
  Future<void> addNewTodo(TodoEntity todo);

  Future<void> deleteTodo(List<String> idList);

  Stream<List<TodoEntity>> todos();

  Future<void> updateTodo(TodoEntity todo);
>>>>>>> 412891a503583b5b9acc39e16dd5964a156ff7c3
}
