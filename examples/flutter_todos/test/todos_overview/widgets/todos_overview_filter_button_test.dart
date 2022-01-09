// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class MockTodosOverviewBloc
    extends MockBloc<TodosOverviewEvent, TodosOverviewState>
    implements TodosOverviewBloc {}

extension on CommonFinders {
  Finder filterMenuItem({
    required TodosViewFilter filter,
    required String title,
  }) {
    return find.descendant(
      of: find.byWidgetPredicate(
        (w) => w is PopupMenuItem && w.value == filter,
      ),
      matching: find.text(title),
    );
  }
}

extension on WidgetTester {
  Future<void> openPopup() async {
    await tap(find.byType(TodosOverviewFilterButton));
    await pumpAndSettle();
  }
}

void main() {
  group('TodosOverviewFilterButton', () {
    late TodosOverviewBloc todosOverviewBloc;

    setUp(() {
      todosOverviewBloc = MockTodosOverviewBloc();
      when(() => todosOverviewBloc.state).thenReturn(
        const TodosOverviewState(
          status: TodosOverviewStatus.success,
          todos: [],
        ),
      );
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: todosOverviewBloc,
        child: const TodosOverviewFilterButton(),
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(
          () => const TodosOverviewFilterButton(),
          returnsNormally,
        );
      });
    });

    testWidgets('renders filter list icon', (tester) async {
      await tester.pumpApp(buildSubject());

      expect(
        find.byIcon(Icons.filter_list_rounded),
        findsOneWidget,
      );
    });

    group('internal PopupMenuButton', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(
          find.bySpecificType<PopupMenuButton<TodosViewFilter>>(),
          findsOneWidget,
        );
      });

      testWidgets('has initial value set to active filter', (tester) async {
        when(() => todosOverviewBloc.state).thenReturn(
          const TodosOverviewState(
            filter: TodosViewFilter.completedOnly,
          ),
        );

        await tester.pumpApp(buildSubject());

        final popupMenuButton = tester.widget<PopupMenuButton<TodosViewFilter>>(
          find.bySpecificType<PopupMenuButton<TodosViewFilter>>(),
        );
        expect(
          popupMenuButton.initialValue,
          equals(TodosViewFilter.completedOnly),
        );
      });

      testWidgets(
        'renders items for each filter type when pressed',
        (tester) async {
          await tester.pumpApp(buildSubject());
          await tester.openPopup();

          expect(
            find.filterMenuItem(
              filter: TodosViewFilter.all,
              title: l10n.todosOverviewFilterAll,
            ),
            findsOneWidget,
          );
          expect(
            find.filterMenuItem(
              filter: TodosViewFilter.activeOnly,
              title: l10n.todosOverviewFilterActiveOnly,
            ),
            findsOneWidget,
          );
          expect(
            find.filterMenuItem(
              filter: TodosViewFilter.completedOnly,
              title: l10n.todosOverviewFilterCompletedOnly,
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'adds TodosOverviewFilterChanged '
        'to TodosOverviewBloc '
        'when new filter is pressed',
        (tester) async {
          when(() => todosOverviewBloc.state).thenReturn(
            const TodosOverviewState(
              filter: TodosViewFilter.all,
            ),
          );

          await tester.pumpApp(buildSubject());
          await tester.openPopup();

          await tester.tap(find.text(l10n.todosOverviewFilterCompletedOnly));
          await tester.pumpAndSettle();

          verify(
            () => todosOverviewBloc.add(
              const TodosOverviewFilterChanged(TodosViewFilter.completedOnly),
            ),
          ).called(1);
        },
      );
    });
  });
}
