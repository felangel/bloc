import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:todos_repository/todos_repository.dart';

void main() {
  group('TodosViewFilter', () {
    final completedTodo = Todo(
      id: '0',
      title: 'completed',
      isCompleted: true,
    );

    final incompleteTodo = Todo(
      id: '1',
      title: 'incomplete',
    );

    group('apply', () {
      test('always returns true when filter is .all', () {
        expect(
          TodosViewFilter.all.apply(completedTodo),
          isTrue,
        );
        expect(
          TodosViewFilter.all.apply(incompleteTodo),
          isTrue,
        );
      });

      test(
        'returns true when filter is .activeOnly '
        'and the todo is incomplete',
        () {
          expect(
            TodosViewFilter.activeOnly.apply(completedTodo),
            isFalse,
          );
          expect(
            TodosViewFilter.activeOnly.apply(incompleteTodo),
            isTrue,
          );
        },
      );

      test(
          'returns true when filter is .completedOnly '
          'and the todo is completed', () {
        expect(
          TodosViewFilter.completedOnly.apply(incompleteTodo),
          isFalse,
        );
        expect(
          TodosViewFilter.completedOnly.apply(completedTodo),
          isTrue,
        );
      });
    });

    group('applyAll', () {
      test('correctly filters provided iterable based on selected filter', () {
        final allTodos = [completedTodo, incompleteTodo];

        expect(
          TodosViewFilter.all.applyAll(allTodos),
          equals(allTodos),
        );
        expect(
          TodosViewFilter.activeOnly.applyAll(allTodos),
          equals([incompleteTodo]),
        );
        expect(
          TodosViewFilter.completedOnly.applyAll(allTodos),
          equals([completedTodo]),
        );
      });
    });
  });
}
