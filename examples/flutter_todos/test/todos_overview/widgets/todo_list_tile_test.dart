import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:todos_api/todos_api.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TodoListTile', () {
    final uncompletedTodo = mockTodos.first.copyWith(isCompleted: false);
    final completedTodo = mockTodos.first.copyWith(isCompleted: true);

    final onToggleCompletedCalls = <bool>[];
    var onDismissedCallCount = 0;
    var onTapCallCount = 0;

    final dismissibleKey =
        Key('todoListTile_dismissible_${uncompletedTodo.id}');

    setUpAll(commonSetUpAll);

    Future<void> pumpSubject(
      WidgetTester tester, {
      Todo? todo,
    }) async {
      await tester.pumpApp(
        TodoListTile(
          todo: todo ?? uncompletedTodo,
          onToggleCompleted: onToggleCompletedCalls.add,
          onDismissed: () => onDismissedCallCount++,
          onTap: () => onTapCallCount++,
        ),
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(
          () => TodoListTile(todo: uncompletedTodo),
          returnsNormally,
        );
      });
    });

    group('checkbox', () {
      testWidgets('is rendered', (tester) async {
        await pumpSubject(tester);

        expect(find.byType(Checkbox), findsOneWidget);
      });

      testWidgets('is checked when todo is completed', (tester) async {
        await pumpSubject(
          tester,
          todo: completedTodo,
        );

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isTrue);
      });

      testWidgets('is unchecked when todo is not completed', (tester) async {
        await pumpSubject(
          tester,
          todo: uncompletedTodo,
        );

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isFalse);
      });

      testWidgets(
        'calls onToggleCompleted with correct value when tapped',
        (tester) async {
          await pumpSubject(
            tester,
            todo: uncompletedTodo,
          );

          await tester.tap(find.byType(Checkbox));

          expect(onToggleCompletedCalls, equals([true]));
        },
      );
    });

    group('dismissible', () {
      testWidgets('is rendered', (tester) async {
        await pumpSubject(tester);

        expect(find.byType(Dismissible), findsOneWidget);
        expect(find.byKey(dismissibleKey), findsOneWidget);
      });

      testWidgets('calls onDismissed when swiped to the left', (tester) async {
        await pumpSubject(tester);

        await tester.fling(
          find.byKey(dismissibleKey),
          const Offset(-300, 0),
          3000,
        );
        await tester.pumpAndSettle();

        expect(onDismissedCallCount, equals(1));
      });
    });

    testWidgets('calls onTap when pressed', (tester) async {
      await pumpSubject(tester);

      await tester.tap(find.byType(TodoListTile));

      expect(onTapCallCount, equals(1));
    });

    group('todo title', () {
      testWidgets('is rendered', (tester) async {
        await pumpSubject(tester);

        expect(find.text(uncompletedTodo.title), findsOneWidget);
      });

      testWidgets('is struckthrough when todo is completed', (tester) async {
        await pumpSubject(
          tester,
          todo: completedTodo,
        );

        final text = tester.widget<Text>(find.text(completedTodo.title));
        expect(
          text.style,
          isA<TextStyle>().having(
            (s) => s.decoration,
            'decoration',
            TextDecoration.lineThrough,
          ),
        );
      });
    });

    group('todo description', () {
      testWidgets('is rendered', (tester) async {
        await pumpSubject(tester);

        expect(find.text(uncompletedTodo.description), findsOneWidget);
      });
    });
  });
}
