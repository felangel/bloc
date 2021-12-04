import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  setUpAll(commonSetUpAll);

  group('TodosOverviewPage', () {
    late TodosRepository todosRepository;

    setUp(() {
      todosRepository = MockTodosRepository();
    });

    testWidgets('renders TodosOverviewView', (tester) async {
      await tester.pumpApp(
        const TodosOverviewPage(),
      );

      expect(find.byType(TodosOverviewView), findsOneWidget);
    });

    testWidgets(
      'subscribes to todos from repository on initialization',
      (tester) async {
        await tester.pumpApp(
          const TodosOverviewPage(),
          todosRepository: todosRepository,
        );

        verify(() => todosRepository.getTodos()).called(1);
      },
    );
  });

  group('TodosOverviewView', () {
    late MockNavigator navigator;
    late TodosOverviewBloc todosOverviewBloc;

    setUp(() {
      navigator = MockNavigator();
      when(() => navigator.push(any())).thenAnswer((_) async {});

      todosOverviewBloc = MockTodosOverviewBloc();
    });

    Widget buildSubject() {
      return MockNavigatorProvider(
        navigator: navigator,
        child: BlocProvider.value(
          value: todosOverviewBloc,
          child: const TodosOverviewView(),
        ),
      );
    }

    testWidgets(
      'renders AppBar with title text',
      (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text(l10n.todosOverviewAppBarTitle),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders error snackbar '
      'when status changes to failure',
      (tester) async {
        whenListen<TodosOverviewState>(
          todosOverviewBloc,
          Stream.fromIterable([
            const TodosOverviewState(),
            const TodosOverviewState(
              status: TodosOverviewStatus.failure,
            ),
          ]),
        );

        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text(l10n.todosOverviewErrorSnackbarText),
          ),
          findsOneWidget,
        );
      },
    );

    group('TodoDeletionConfirmationSnackBar', () {
      setUp(() {
        when(() => todosOverviewBloc.state).thenReturn(
          TodosOverviewState(
            lastDeletedTodo: mockTodos.first,
          ),
        );
        whenListen<TodosOverviewState>(
          todosOverviewBloc,
          Stream.fromIterable([
            const TodosOverviewState(),
            TodosOverviewState(
              lastDeletedTodo: mockTodos.first,
            ),
          ]),
        );
      });

      testWidgets('is rendered when lastDeletedTodo changes', (tester) async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();

        expect(
          find.byType(TodoDeletionConfirmationSnackBarContent),
          findsOneWidget,
        );

        final snackBar = tester.widget<TodoDeletionConfirmationSnackBarContent>(
          find.byType(TodoDeletionConfirmationSnackBarContent),
        );

        expect(
          snackBar.todo,
          equals(mockTodos.first),
        );
      });

      testWidgets(
        'adds TodosOverviewUndoDeletionRequested '
        'to TodosOverviewBloc '
        'when onUndo is called',
        (tester) async {
          await tester.pumpApp(buildSubject());
          await tester.pumpAndSettle();

          final snackBar =
              tester.widget<TodoDeletionConfirmationSnackBarContent>(
            find.byType(TodoDeletionConfirmationSnackBarContent),
          );

          snackBar.onUndo();

          verify(
            () => todosOverviewBloc
                .add(const TodosOverviewUndoDeletionRequested()),
          ).called(1);
        },
      );
    });

    group('when todos is empty', () {
      setUp(() {
        when(() => todosOverviewBloc.state)
            .thenReturn(const TodosOverviewState());
      });

      testWidgets(
        'renders nothing '
        'when status is initial or error',
        (tester) async {
          await tester.pumpApp(buildSubject());

          expect(find.byType(ListView), findsNothing);
          expect(find.byType(CupertinoActivityIndicator), findsNothing);
        },
      );

      testWidgets(
        'renders loading indicator '
        'when status is loading',
        (tester) async {
          when(() => todosOverviewBloc.state).thenReturn(
            const TodosOverviewState(
              status: TodosOverviewStatus.loading,
            ),
          );

          await tester.pumpApp(buildSubject());

          expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'renders todos empty text '
        'when status is success',
        (tester) async {
          when(() => todosOverviewBloc.state).thenReturn(
            const TodosOverviewState(
              status: TodosOverviewStatus.success,
            ),
          );

          await tester.pumpApp(buildSubject());

          expect(find.text(l10n.todosOverviewEmptyText), findsOneWidget);
        },
      );
    });

    group('when todos is not empty', () {
      setUp(() {
        when(() => todosOverviewBloc.state).thenReturn(
          TodosOverviewState(
            status: TodosOverviewStatus.success,
            todos: mockTodos,
          ),
        );
      });

      testWidgets('renders ListView with TodoListTiles', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(TodoListTile), findsNWidgets(mockTodos.length));
      });

      testWidgets(
        'adds TodosOverviewTodoCompletionToggled '
        'to TodosOverviewBloc '
        'when TodoListTile.onToggleCompleted is called',
        (tester) async {
          await tester.pumpApp(buildSubject());

          final todo = mockTodos.first;

          final todoListTile =
              tester.widget<TodoListTile>(find.byType(TodoListTile).first);
          todoListTile.onToggleCompleted!(!todo.isCompleted);

          verify(
            () => todosOverviewBloc.add(
              TodosOverviewTodoCompletionToggled(
                todo: todo,
                isCompleted: !todo.isCompleted,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'adds TodosOverviewTodoDeleted '
        'to TodosOverviewBloc '
        'when TodoListTile.onDismissed is called',
        (tester) async {
          await tester.pumpApp(buildSubject());

          final todo = mockTodos.first;

          final todoListTile =
              tester.widget<TodoListTile>(find.byType(TodoListTile).first);
          todoListTile.onDismissed!(DismissDirection.startToEnd);

          verify(() => todosOverviewBloc.add(TodosOverviewTodoDeleted(todo)))
              .called(1);
        },
      );

      testWidgets(
        'navigates to EditTodoPage '
        'when TodoListTile.onTap is called',
        (tester) async {
          await tester.pumpApp(buildSubject());

          final todoListTile =
              tester.widget<TodoListTile>(find.byType(TodoListTile).first);
          todoListTile.onTap!();

          verify(() => navigator.push(any(that: isRoute<void>()))).called(1);
        },
      );
    });
  });
}
