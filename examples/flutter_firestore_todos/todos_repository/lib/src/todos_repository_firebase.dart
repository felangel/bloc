// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todos_repository/todos_repository.dart';

class FirebaseTodosRepository implements TodosRepository {
  final todoCollection = Firestore.instance.collection('todos');

  @override
  Future<void> addNewTodo(TodoEntity todo) {
    return todoCollection.add(todo.toDocument());
  }

  @override
  Future<void> deleteTodo(List<String> idList) async {
    await Future.wait<void>(
      idList.map((id) {
        return todoCollection.document(id).delete();
      }),
    );
  }

  @override
  Stream<List<TodoEntity>> todos() {
    return todoCollection.snapshots().map((snapshot) {
      return snapshot.documents
          .map((doc) => TodoEntity.fromSnapshot(doc))
          .toList();
    });
  }

  @override
  Future<void> updateTodo(TodoEntity update) {
    return todoCollection.document(update.id).updateData(update.toDocument());
  }
}
