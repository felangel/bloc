// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage_todos_api/local_storage_todos_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_api/todos_api.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('LocalStorageTodosApi', () {
    late SharedPreferences plugin;

    final todos = [
      Todo(
        id: '1',
        title: 'title 1',
        description: 'description 1',
      ),
      Todo(
        id: '2',
        title: 'title 2',
        description: 'description 2',
      ),
      Todo(
        id: '3',
        title: 'title 3',
        description: 'description 3',
        isCompleted: true,
      ),
    ];

    setUp(() {
      plugin = MockSharedPreferences();
      when(() => plugin.getString(any())).thenReturn(json.encode(todos));
      when(() => plugin.setString(any(), any())).thenAnswer((_) async => true);
    });

    LocalStorageTodosApi createSubject() {
      return LocalStorageTodosApi(
        plugin: plugin,
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(
          createSubject,
          returnsNormally,
        );
      });

      test('initializes the todos stream', () {
        final subject = createSubject();

        expect(subject.getTodos(), emits(todos));
        verify(() => plugin.getString(LocalStorageTodosApi.kTodosCollectionKey))
            .called(1);
      });
    });

    test('getTodos returns stream of current list todos', () {
      expect(
        createSubject().getTodos(),
        emits(todos),
      );
    });

    group('saveTodo', () {
      test('saves new todos', () {
        final newTodo = Todo(
          id: '4',
          title: 'title 4',
          description: 'description 4',
        );

        final newTodos = [...todos, newTodo];

        final subject = createSubject();

        expect(subject.saveTodo(newTodo), completes);
        expect(subject.getTodos(), emits(newTodos));

        verify(() => plugin.setString(
              LocalStorageTodosApi.kTodosCollectionKey,
              json.encode(newTodos),
            )).called(1);
      });

      test('updates existing todos', () {
        final updatedTodo = Todo(
          id: '1',
          title: 'new title 1',
          description: 'new description 1',
          isCompleted: true,
        );
        final newTodos = [updatedTodo, ...todos.sublist(1)];

        final subject = createSubject();

        expect(subject.saveTodo(updatedTodo), completes);
        expect(subject.getTodos(), emits(newTodos));

        verify(() => plugin.setString(
              LocalStorageTodosApi.kTodosCollectionKey,
              json.encode(newTodos),
            )).called(1);
      });
    });

    group('deleteTodo', () {
      test('deletes existing todos', () {
        final newTodos = todos.sublist(1);

        final subject = createSubject();

        expect(subject.deleteTodo(todos[0].id), completes);
        expect(subject.getTodos(), emits(newTodos));

        verify(() => plugin.setString(
              LocalStorageTodosApi.kTodosCollectionKey,
              json.encode(newTodos),
            )).called(1);
      });

      test(
        'throws TodoNotFoundException if todo '
        'with provided id is not found',
        () {
          final subject = createSubject();

          expect(
            () => subject.deleteTodo('non-existing-id'),
            throwsA(isA<TodoNotFoundException>()),
          );
        },
      );
    });

    group('deleteIsCompleted', () {
      test('deletes all isCompleted todos', () {
        final newTodos = todos.where((todo) => !todo.isCompleted).toList();

        final subject = createSubject();

        expect(subject.clearCompleted(), completes);
        expect(subject.getTodos(), emits(newTodos));

        verify(() => plugin.setString(
              LocalStorageTodosApi.kTodosCollectionKey,
              json.encode(newTodos),
            )).called(1);
      });
    });
  });
}
