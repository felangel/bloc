// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/edit_todo/edit_todo.dart';
import 'package:todos_repository/todos_repository.dart';

void main() {
  group('EditTodoState', () {
    final mockInitialTodo = Todo(
      id: '1',
      title: 'title 1',
      description: 'description 1',
    );

    EditTodoState createSubject({
      EditTodoStatus status = EditTodoStatus.initial,
      Todo? initialTodo,
      String title = '',
      String description = '',
    }) {
      return EditTodoState(
        status: status,
        initialTodo: initialTodo,
        title: title,
        description: description,
      );
    }

    test('supports value equality', () {
      expect(
        createSubject(),
        equals(createSubject()),
      );
    });

    test('props are correct', () {
      expect(
        createSubject(
          status: EditTodoStatus.initial,
          initialTodo: mockInitialTodo,
          title: 'title',
          description: 'description',
        ).props,
        equals(<Object?>[
          EditTodoStatus.initial, // status
          mockInitialTodo, // initialTodo
          'title', // title
          'description', // description
        ]),
      );
    });

    test('isNewTodo returns true when a new todo is being created', () {
      expect(
        createSubject(
          initialTodo: null,
        ).isNewTodo,
        isTrue,
      );
    });

    group('copyWith', () {
      test('returns the same object if not arguments are provided', () {
        expect(
          createSubject().copyWith(),
          equals(createSubject()),
        );
      });

      test('retains the old value for every parameter if null is provided', () {
        expect(
          createSubject().copyWith(
            status: null,
            initialTodo: null,
            title: null,
            description: null,
          ),
          equals(createSubject()),
        );
      });

      test('replaces every non-null parameter', () {
        expect(
          createSubject().copyWith(
            status: EditTodoStatus.success,
            initialTodo: mockInitialTodo,
            title: 'title',
            description: 'description',
          ),
          equals(
            createSubject(
              status: EditTodoStatus.success,
              initialTodo: mockInitialTodo,
              title: 'title',
              description: 'description',
            ),
          ),
        );
      });
    });
  });
}
