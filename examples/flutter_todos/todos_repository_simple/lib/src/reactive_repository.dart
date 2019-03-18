// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:core';

import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';
import 'package:todos_repository_core/todos_repository_core.dart';

/// A class that glues together our local file storage and web client. It has a
/// clear responsibility: Load Todos and Persist todos.
class ReactiveTodosRepositoryFlutter implements ReactiveTodosRepository {
  final TodosRepository _repository;
  final BehaviorSubject<List<TodoEntity>> _subject;
  bool _loaded = false;

  ReactiveTodosRepositoryFlutter({
    @required TodosRepository repository,
    List<TodoEntity> seedValue,
  })  : this._repository = repository,
        this._subject = BehaviorSubject<List<TodoEntity>>(seedValue: seedValue);

  @override
  Future<void> addNewTodo(TodoEntity todo) async {
    _subject.add(List.unmodifiable([]
      ..addAll(_subject.value ?? [])
      ..add(todo)));

    await _repository.saveTodos(_subject.value);
  }

  @override
  Future<void> deleteTodo(List<String> idList) async {
    _subject.add(
      List<TodoEntity>.unmodifiable(_subject.value.fold<List<TodoEntity>>(
        <TodoEntity>[],
        (prev, entity) {
          return idList.contains(entity.id) ? prev : (prev..add(entity));
        },
      )),
    );

    await _repository.saveTodos(_subject.value);
  }

  @override
  Stream<List<TodoEntity>> todos() {
    if (!_loaded) _loadTodos();

    return _subject.stream;
  }

  void _loadTodos() {
    _loaded = true;

    _repository.loadTodos().then((entities) {
      _subject.add(List<TodoEntity>.unmodifiable(
        []..addAll(_subject.value ?? [])..addAll(entities),
      ));
    });
  }

  @override
  Future<void> updateTodo(TodoEntity update) async {
    _subject.add(
      List<TodoEntity>.unmodifiable(_subject.value.fold<List<TodoEntity>>(
        <TodoEntity>[],
        (prev, entity) => prev..add(entity.id == update.id ? update : entity),
      )),
    );

    await _repository.saveTodos(_subject.value);
  }
}
