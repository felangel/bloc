// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart'
    hide TodosViewFilter;
import 'package:mocktail/mocktail.dart';
import 'package:todos_api/todos_api.dart';

import '../../helpers/helpers.dart';

extension on CommonFinders {
  Finder optionMenuItem({
    bool enabled = true,
    required String title,
  }) {
    return find.descendant(
      of: find.byWidgetPredicate(
        (w) => w is PopupMenuItem && w.enabled == enabled,
      ),
      matching: find.text(title),
    );
  }
}

extension on WidgetTester {
  Future<void> openPopup() async {
    await tap(find.byType(TodosOverviewOptionsButton));
    await pumpAndSettle();
  }
}

void main() {
  group('TodosOverviewOptionsButton', () {
    late TodosOverviewBloc todosOverviewBloc;

    setUpAll(commonSetUpAll);

    setUp(() {
      todosOverviewBloc = MockTodosOverviewBloc();
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: todosOverviewBloc,
        child: const TodosOverviewOptionsButton(),
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(
          () => const TodosOverviewOptionsButton(),
          returnsNormally,
        );
      });
    });

    group('internal PopupMenuButton', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(
          find.bySpecificType<PopupMenuButton<TodosOverviewOption>>(),
          findsOneWidget,
        );
        expect(
          find.byTooltip(l10n.todosOverviewOptionsTooltip),
          findsOneWidget,
        );
      });

      group('mark all todos button', () {
        testWidgets('is disabled when there are no todos', (tester) async {
          when(() => todosOverviewBloc.state)
              .thenReturn(const TodosOverviewState(todos: []));
          await tester.pumpApp(buildSubject());
          await tester.openPopup();

          expect(
            find.optionMenuItem(
              title: l10n.todosOverviewOptionsMarkAllIncomplete,
              enabled: false,
            ),
            findsOneWidget,
          );
        });

        testWidgets(
          'renders mark all complete button '
          'when not all todos are marked completed',
          (tester) async {
            when(() => todosOverviewBloc.state).thenReturn(TodosOverviewState(
              todos: [
                Todo(title: 'a', isCompleted: true),
                Todo(title: 'b', isCompleted: false),
              ],
            ));
            await tester.pumpApp(buildSubject());
            await tester.openPopup();

            expect(
              find.optionMenuItem(
                title: l10n.todosOverviewOptionsMarkAllComplete,
              ),
              findsOneWidget,
            );
          },
        );

        testWidgets(
          'renders mark all incomplete button '
          'when all todos are marked completed',
          (tester) async {
            when(() => todosOverviewBloc.state).thenReturn(TodosOverviewState(
              todos: [
                Todo(title: 'a', isCompleted: true),
                Todo(title: 'b', isCompleted: true),
              ],
            ));
            await tester.pumpApp(buildSubject());
            await tester.openPopup();

            expect(
              find.optionMenuItem(
                title: l10n.todosOverviewOptionsMarkAllIncomplete,
              ),
              findsOneWidget,
            );
          },
        );

        testWidgets(
          'adds TodosOverviewToggleAllRequested '
          'to TodosOverviewBloc '
          'when tapped',
          (tester) async {
            when(() => todosOverviewBloc.state).thenReturn(TodosOverviewState(
              todos: [
                Todo(title: 'a', isCompleted: true),
                Todo(title: 'b', isCompleted: false),
              ],
            ));
            await tester.pumpApp(buildSubject());
            await tester.openPopup();

            await tester.tap(find.optionMenuItem(
              title: l10n.todosOverviewOptionsMarkAllComplete,
            ));

            verify(() => todosOverviewBloc
                .add(const TodosOverviewToggleAllRequested())).called(1);
          },
        );
      });

      group('clear completed button', () {
        testWidgets(
          'is disabled when there are no completed todos',
          (tester) async {
            when(() => todosOverviewBloc.state)
                .thenReturn(const TodosOverviewState(todos: []));
            await tester.pumpApp(buildSubject());
            await tester.openPopup();

            expect(
              find.optionMenuItem(
                title: l10n.todosOverviewOptionsClearCompleted,
                enabled: false,
              ),
              findsOneWidget,
            );
          },
        );

        testWidgets(
          'renders clear completed button '
          'when there are completed todos',
          (tester) async {
            when(() => todosOverviewBloc.state).thenReturn(TodosOverviewState(
              todos: [
                Todo(title: 'a', isCompleted: true),
                Todo(title: 'b', isCompleted: false),
              ],
            ));
            await tester.pumpApp(buildSubject());
            await tester.openPopup();

            expect(
              find.optionMenuItem(
                title: l10n.todosOverviewOptionsClearCompleted,
                enabled: true,
              ),
              findsOneWidget,
            );
          },
        );

        testWidgets(
          'adds TodosOverviewClearCompletedRequested '
          'to TodosOverviewBloc '
          'when tapped',
          (tester) async {
            when(() => todosOverviewBloc.state).thenReturn(TodosOverviewState(
              todos: [
                Todo(title: 'a', isCompleted: true),
                Todo(title: 'b', isCompleted: false),
              ],
            ));
            await tester.pumpApp(buildSubject());
            await tester.openPopup();

            await tester.tap(find.optionMenuItem(
              title: l10n.todosOverviewOptionsClearCompleted,
            ));

            verify(() => todosOverviewBloc
                .add(const TodosOverviewClearCompletedRequested())).called(1);
          },
        );
      });
    });
  });
}
