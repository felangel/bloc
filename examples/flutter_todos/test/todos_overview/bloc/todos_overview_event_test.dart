// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TodosOverviewEvent', () {
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

    group('TodosOverviewTodoSaved', () {
      test('supports value equality', () {
        expect(
          TodosOverviewTodoSaved(mockTodos.first),
          equals(TodosOverviewTodoSaved(mockTodos.first)),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewTodoSaved(mockTodos.first).props,
          equals(<Object?>[
            mockTodos.first, // todo
          ]),
        );
      });
    });

    group('TodosOverviewTodoCompletionToggled', () {
      test('supports value equality', () {
        expect(
          TodosOverviewTodoCompletionToggled(
            todo: mockTodos.first,
            isCompleted: true,
          ),
          equals(TodosOverviewTodoCompletionToggled(
            todo: mockTodos.first,
            isCompleted: true,
          ),),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewTodoCompletionToggled(
            todo: mockTodos.first,
            isCompleted: true,
          ).props,
          equals(<Object?>[
            mockTodos.first, // todo
            true, // isCompleted
          ]),
        );
      });
    });

    group('TodosOverviewTodoDeleted', () {
      test('supports value equality', () {
        expect(
          TodosOverviewTodoDeleted(mockTodos.first),
          equals(TodosOverviewTodoDeleted(mockTodos.first)),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewTodoDeleted(mockTodos.first).props,
          equals(<Object?>[
            mockTodos.first, // todo
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
