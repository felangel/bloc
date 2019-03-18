// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:todos_repository_core/todos_repository_core.dart';
import 'package:todos_repository_simple/todos_repository_simple.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

main() {
  group('ReactiveTodosRepository', () {
    List<TodoEntity> createTodos([String task = "Task"]) {
      return [
        TodoEntity(task, "1", "Hallo", false),
        TodoEntity(task, "2", "Friend", false),
        TodoEntity(task, "3", "Yo", false),
      ];
    }

    test('should load todos from the base repo and send them to the client',
        () {
      final todos = createTodos();
      final repository = MockTodosRepository();
      final reactiveRepository = ReactiveTodosRepositoryFlutter(
        repository: repository,
        seedValue: todos,
      );

      when(repository.loadTodos())
          .thenAnswer((_) => Future.value(<TodoEntity>[]));

      expect(reactiveRepository.todos(), emits(todos));
    });

    test('should only load from the base repo once', () {
      final todos = createTodos();
      final repository = MockTodosRepository();
      final reactiveRepository = ReactiveTodosRepositoryFlutter(
        repository: repository,
        seedValue: todos,
      );

      when(repository.loadTodos()).thenAnswer((_) => Future.value(todos));

      expect(reactiveRepository.todos(), emits(todos));
      expect(reactiveRepository.todos(), emits(todos));

      verify(repository.loadTodos()).called(1);
    });

    test('should add todos to the repository and emit the change', () async {
      final todos = createTodos();
      final repository = MockTodosRepository();
      final reactiveRepository = ReactiveTodosRepositoryFlutter(
        repository: repository,
        seedValue: [],
      );

      when(repository.loadTodos())
          .thenAnswer((_) => new Future.value(<TodoEntity>[]));
      when(repository.saveTodos(todos)).thenAnswer((_) => Future.value());

      await reactiveRepository.addNewTodo(todos.first);

      verify(repository.saveTodos(any));
      expect(reactiveRepository.todos(), emits([todos.first]));
    });

    test('should update a todo in the repository and emit the change',
        () async {
      final todos = createTodos();
      final repository = MockTodosRepository();
      final reactiveRepository = ReactiveTodosRepositoryFlutter(
        repository: repository,
        seedValue: todos,
      );
      final update = createTodos("task");

      when(repository.loadTodos()).thenAnswer((_) => Future.value(todos));
      when(repository.saveTodos(any)).thenAnswer((_) => Future.value());

      await reactiveRepository.updateTodo(update.first);

      verify(repository.saveTodos(any));
      expect(
        reactiveRepository.todos(),
        emits([update[0], todos[1], todos[2]]),
      );
    });

    test('should remove todos from the repo and emit the change', () async {
      final repository = MockTodosRepository();
      final todos = createTodos();
      final reactiveRepository = ReactiveTodosRepositoryFlutter(
        repository: repository,
        seedValue: todos,
      );
      final future = Future.value(todos);

      when(repository.loadTodos()).thenAnswer((_) => future);
      when(repository.saveTodos(any)).thenAnswer((_) => Future.value());

      await reactiveRepository.deleteTodo([todos.first.id, todos.last.id]);

      verify(repository.saveTodos(any));
      expect(reactiveRepository.todos(), emits([todos[1]]));
    });
  });
}
