// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:todos_repository/todos_repository.dart';

void main() {
  group('TodosOverviewEvent', () {
    final mockTodo = Todo(
      id: '1',
      title: 'title 1',
      description: 'description 1',
    );

    group('TodosOverviewSubscriptionRequested', () {
      test('supports value equality', () {
        expect(
          TodosOverviewSubscriptionRequested(),
          equals(TodosOverviewSubscriptionRequested()),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewSubscriptionRequested().props,
          equals(<Object?>[]),
        );
      });
    });

    group('TodosOverviewTodoCompletionToggled', () {
      test('supports value equality', () {
        expect(
          TodosOverviewTodoCompletionToggled(
            todo: mockTodo,
            isCompleted: true,
          ),
          equals(
            TodosOverviewTodoCompletionToggled(
              todo: mockTodo,
              isCompleted: true,
            ),
          ),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewTodoCompletionToggled(
            todo: mockTodo,
            isCompleted: true,
          ).props,
          equals(<Object?>[
            mockTodo, // todo
            true, // isCompleted
          ]),
        );
      });
    });

    group('TodosOverviewTodoDeleted', () {
      test('supports value equality', () {
        expect(
          TodosOverviewTodoDeleted(mockTodo),
          equals(TodosOverviewTodoDeleted(mockTodo)),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewTodoDeleted(mockTodo).props,
          equals(<Object?>[
            mockTodo, // todo
          ]),
        );
      });
    });

    group('TodosOverviewUndoDeletionRequested', () {
      test('supports value equality', () {
        expect(
          TodosOverviewUndoDeletionRequested(),
          equals(TodosOverviewUndoDeletionRequested()),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewUndoDeletionRequested().props,
          equals(<Object?>[]),
        );
      });
    });

    group('TodosOverviewFilterChanged', () {
      test('supports value equality', () {
        expect(
          TodosOverviewFilterChanged(TodosViewFilter.all),
          equals(TodosOverviewFilterChanged(TodosViewFilter.all)),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewFilterChanged(TodosViewFilter.all).props,
          equals(<Object?>[
            TodosViewFilter.all, // filter
          ]),
        );
      });
    });

    group('TodosOverviewToggleAllRequested', () {
      test('supports value equality', () {
        expect(
          TodosOverviewToggleAllRequested(),
          equals(TodosOverviewToggleAllRequested()),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewToggleAllRequested().props,
          equals(<Object?>[]),
        );
      });
    });

    group('TodosOverviewClearCompletedRequested', () {
      test('supports value equality', () {
        expect(
          TodosOverviewClearCompletedRequested(),
          equals(TodosOverviewClearCompletedRequested()),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewClearCompletedRequested().props,
          equals(<Object?>[]),
        );
      });
    });
  });
}
