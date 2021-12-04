// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:todos_repository/todos_repository.dart';

void main() {
  final mockTodo = Todo(
    id: '1',
    title: 'title 1',
    description: 'description 1',
  );
  final mockTodos = [mockTodo];
  group('TodosOverviewState', () {
    TodosOverviewState createSubject({
      TodosOverviewStatus status = TodosOverviewStatus.initial,
      List<Todo>? todos,
      TodosViewFilter filter = TodosViewFilter.all,
      Todo? lastDeletedTodo,
    }) {
      return TodosOverviewState(
        status: status,
        todos: todos ?? mockTodos,
        filter: filter,
        lastDeletedTodo: lastDeletedTodo,
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
          status: TodosOverviewStatus.initial,
          todos: mockTodos,
          filter: TodosViewFilter.all,
          lastDeletedTodo: null,
        ).props,
        equals(<Object?>[
          TodosOverviewStatus.initial, // status
          mockTodos, // todos
          TodosViewFilter.all, // filter
          null, // lastDeletedTodo
        ]),
      );
    });

    test('filteredTodos returns todos filtered by filter', () {
      expect(
        createSubject(
          todos: mockTodos,
          filter: TodosViewFilter.completedOnly,
        ).filteredTodos,
        equals(mockTodos.where((todo) => todo.isCompleted).toList()),
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
            todos: null,
            filter: null,
            lastDeletedTodo: null,
          ),
          equals(createSubject()),
        );
      });

      test('replaces every non-null parameter', () {
        expect(
          createSubject().copyWith(
            status: () => TodosOverviewStatus.success,
            todos: () => [],
            filter: () => TodosViewFilter.completedOnly,
            lastDeletedTodo: () => mockTodo,
          ),
          equals(
            createSubject(
              status: TodosOverviewStatus.success,
              todos: [],
              filter: TodosViewFilter.completedOnly,
              lastDeletedTodo: mockTodo,
            ),
          ),
        );
      });
    });

    test('can copyWith null lastDeletedTodo', () {
      expect(
        createSubject(lastDeletedTodo: mockTodo).copyWith(
          lastDeletedTodo: () => null,
        ),
        equals(createSubject(lastDeletedTodo: null)),
      );
    });
  });
}
