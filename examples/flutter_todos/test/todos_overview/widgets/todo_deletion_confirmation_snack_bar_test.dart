import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  final todo = Todo(
    id: '1',
    title: 'title 1',
    description: 'description 1',
  );

  group('TodoDeletionConfirmationSnackBar', () {
    group('constructor', () {
      test('works properly', () {
        expect(
          () => TodoDeletionConfirmationSnackBar(
            todo: todo,
            onUndo: () {},
          ),
          returnsNormally,
        );
      });

      test('returns a SnackBar widget', () {
        expect(
          TodoDeletionConfirmationSnackBar(
            todo: todo,
            onUndo: () {},
          ),
          isA<SnackBar>(),
        );
      });

      test('content is a TodoDeletionConfirmationSnackBar widget', () {
        expect(
          TodoDeletionConfirmationSnackBar(
            todo: todo,
            onUndo: () {},
          ).content,
          isA<TodoDeletionConfirmationSnackBarContent>(),
        );
      });
    });
  });

  group('TodoDeletionConfirmationSnackBarContent', () {
    late int onUndoCallCount;

    Widget buildSubject() {
      return TodoDeletionConfirmationSnackBarContent(
        todo: todo,
        onUndo: () => onUndoCallCount++,
      );
    }

    setUp(() {
      onUndoCallCount = 0;
    });

    group('constructor', () {
      test('works properly', () {
        expect(
          () => TodoDeletionConfirmationSnackBarContent(
            todo: todo,
            onUndo: () {},
          ),
          returnsNormally,
        );
      });
    });

    testWidgets('renders title with todo title', (tester) async {
      await tester.pumpApp(buildSubject());

      expect(
        find.text(l10n.todosOverviewTodoDeletedSnackbarText(todo.title)),
        findsOneWidget,
      );
    });

    group('undo TextButton', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.byType(TextButton), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(TextButton),
            matching: find.text(l10n.todosOverviewUndoDeletionButtonText),
          ),
          findsOneWidget,
        );
      });

      testWidgets('calls onUndo when pressed', (tester) async {
        await tester.pumpApp(buildSubject());

        await tester.tap(find.byType(TextButton));

        expect(onUndoCallCount, equals(1));
      });
    });
  });
}
