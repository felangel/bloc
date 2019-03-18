// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:todos_repository_core/todos_repository_core.dart';
import 'package:todos_repository_simple/todos_repository_simple.dart';

/// We create two Mocks for our Web Client and File Storage. We will use these
/// mock classes to verify the behavior of the TodosRepository.
class MockFileStorage extends Mock implements FileStorage {}

class MockWebClient extends Mock implements WebClient {}

main() {
  group('TodosRepository', () {
    List<TodoEntity> createTodos() {
      return [TodoEntity("Task", "1", "Hallo", false)];
    }

    test(
        'should load todos from File Storage if they exist without calling the web client',
        () {
      final fileStorage = MockFileStorage();
      final webClient = MockWebClient();
      final repository = TodosRepositoryFlutter(
        fileStorage: fileStorage,
        webClient: webClient,
      );
      final todos = createTodos();

      // We'll use our mock throughout the tests to set certain conditions. In
      // this first test, we want to mock out our file storage to return a
      // list of Todos that we define here in our test!
      when(fileStorage.loadTodos()).thenAnswer((_) => Future.value(todos));

      expect(repository.loadTodos(), completion(todos));
      verifyNever(webClient.fetchTodos());
    });

    test(
        'should fetch todos from the Web Client if the file storage throws a synchronous error',
        () async {
      final fileStorage = MockFileStorage();
      final webClient = MockWebClient();
      final repository = TodosRepositoryFlutter(
        fileStorage: fileStorage,
        webClient: webClient,
      );
      final todos = createTodos();

      // In this instance, we'll ask our Mock to throw an error. When it does,
      // we expect the web client to be called instead.
      when(fileStorage.loadTodos()).thenThrow("Uh ohhhh");
      when(webClient.fetchTodos()).thenAnswer((_) => Future.value(todos));

      // We check that the correct todos were returned, and that the
      // webClient.fetchTodos method was in fact called!
      expect(await repository.loadTodos(), todos);
      verify(webClient.fetchTodos());
    });

    test(
        'should fetch todos from the Web Client if the File storage returns an async error',
        () async {
      final fileStorage = MockFileStorage();
      final webClient = MockWebClient();
      final repository = TodosRepositoryFlutter(
        fileStorage: fileStorage,
        webClient: webClient,
      );
      final todos = createTodos();

      when(fileStorage.loadTodos()).thenThrow(Exception("Oh no."));
      when(webClient.fetchTodos()).thenAnswer((_) => Future.value(todos));

      expect(await repository.loadTodos(), todos);
      verify(webClient.fetchTodos());
    });

    test('should persist the todos to local disk and the web client', () {
      final fileStorage = MockFileStorage();
      final webClient = MockWebClient();
      final repository = TodosRepositoryFlutter(
        fileStorage: fileStorage,
        webClient: webClient,
      );
      final todos = createTodos();

      when(fileStorage.saveTodos(todos))
          .thenAnswer((_) => Future.value(File('falsch')));
      when(webClient.postTodos(todos)).thenAnswer((_) => Future.value(true));

      // In this case, we just want to verify we're correctly persisting to all
      // the storage mechanisms we care about.
      expect(repository.saveTodos(todos), completes);
      verify(fileStorage.saveTodos(todos));
      verify(webClient.postTodos(todos));
    });
  });
}
