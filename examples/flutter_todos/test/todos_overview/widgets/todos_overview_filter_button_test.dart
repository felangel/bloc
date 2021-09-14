// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

extension on CommonFinders {
  Finder bySpecificType<T>() => find.byType(T);
  Finder filterMenuItem({
    required TodosViewFilter filter,
    required String title,
  }) {
    return find.byWidgetPredicate(
      (w) =>
          w is PopupMenuItem &&
          w.value == filter &&
          w.child is Text &&
          (w.child as Text?)!.data == title,
    );
  }
}

void main() {
  group('TodosOverviewFilterButton', () {
    late TodosOverviewBloc todosOverviewBloc;

    setUpAll(commonSetUpAll);

    setUp(() {
      todosOverviewBloc = MockTodosOverviewBloc();
    });

    Future<void> pumpSubject(WidgetTester tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: todosOverviewBloc,
          child: const TodosOverviewFilterButton(),
        ),
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
      await pumpSubject(tester);

      expect(
        find.byIcon(Icons.filter_list_rounded),
        findsOneWidget,
      );
    });

    group('internal PopupMenuButton', () {
      testWidgets('is rendered', (tester) async {
        await pumpSubject(tester);

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

        await pumpSubject(tester);

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
          await pumpSubject(tester);

          await tester.tap(find.byType(TodosOverviewFilterButton));
          await tester.pumpAndSettle();

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
          when(() => todosOverviewBloc.state)
              .thenReturn(const TodosOverviewState(
            filter: TodosViewFilter.all,
          ));

          await pumpSubject(tester);

          await tester.tap(find.byType(TodosOverviewFilterButton));
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.todosOverviewFilterCompletedOnly));
          await tester.pumpAndSettle();

          verify(() => todosOverviewBloc.add(
                const TodosOverviewFilterChanged(TodosViewFilter.completedOnly),
              )).called(1);
        },
      );
    });
  });
}
