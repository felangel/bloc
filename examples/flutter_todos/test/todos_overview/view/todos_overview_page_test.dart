import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

class MockTodosOverviewBloc
    extends MockBloc<TodosOverviewEvent, TodosOverviewState>
    implements TodosOverviewBloc {}

void main() {
  final mockTodos = [
    Todo(
      id: '1',
      title: 'title 1',
      description: 'description 1',
    ),
    Todo(
      id: '2',
      title: 'title 2',
      description: 'description 2',
    ),
    Todo(
      id: '3',
      title: 'title 3',
      description: 'description 3',
      isCompleted: true,
    ),
  ];

  late TodosRepository todosRepository;

  group('TodosOverviewPage', () {
    setUp(() {
      todosRepository = MockTodosRepository();
      when(todosRepository.getTodos).thenAnswer((_) => const Stream.empty());
    });

    testWidgets('renders TodosOverviewView', (tester) async {
      await tester.pumpApp(
        const TodosOverviewPage(),
        todosRepository: todosRepository,
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
      when(() => navigator.push<void>(any())).thenAnswer((_) async {});

      todosOverviewBloc = MockTodosOverviewBloc();
      when(() => todosOverviewBloc.state).thenReturn(
        TodosOverviewState(
          status: TodosOverviewStatus.success,
          todos: mockTodos,
        ),
      );

      todosRepository = MockTodosRepository();
      when(todosRepository.getTodos).thenAnswer((_) => const Stream.empty());
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
        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );

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

        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );
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
        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));

        expect(
          snackBar.content,
          isA<Text>().having(
            (text) => text.data,
            'text',
            contains(mockTodos.first.title),
          ),
        );
      });

      testWidgets(
        'adds TodosOverviewUndoDeletionRequested '
        'to TodosOverviewBloc '
        'when onUndo is called',
        (tester) async {
          await tester.pumpApp(
            buildSubject(),
            todosRepository: todosRepository,
          );
          await tester.pumpAndSettle();

          final snackBarAction = tester.widget<SnackBarAction>(
            find.byType(SnackBarAction),
          );

          snackBarAction.onPressed();

          verify(
            () => todosOverviewBloc.add(
              const TodosOverviewUndoDeletionRequested(),
            ),
          ).called(1);
        },
      );
    });

    group('when todos is empty', () {
      setUp(() {
        when(
          () => todosOverviewBloc.state,
        ).thenReturn(const TodosOverviewState());
      });

      testWidgets(
        'renders nothing '
        'when status is initial or error',
        (tester) async {
          await tester.pumpApp(
            buildSubject(),
            todosRepository: todosRepository,
          );

          expect(find.byType(ListView), findsNothing);
          expect(find.byType(CupertinoActivityIndicator), findsNothing);
        },
      );

      testWidgets(
        'renders loading indicator '
        'when status is loading',
        (tester) async {
          when(() => todosOverviewBloc.state).thenReturn(
            const TodosOverviewState(status: TodosOverviewStatus.loading),
          );

          await tester.pumpApp(
            buildSubject(),
            todosRepository: todosRepository,
          );

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

          await tester.pumpApp(
            buildSubject(),
            todosRepository: todosRepository,
          );

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
        await tester.pumpApp(
          buildSubject(),
          todosRepository: todosRepository,
        );

        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(TodoListTile), findsNWidgets(mockTodos.length));
      });

      testWidgets(
        'adds TodosOverviewTodoCompletionToggled '
        'to TodosOverviewBloc '
        'when TodoListTile.onToggleCompleted is called',
        (tester) async {
          await tester.pumpApp(
            buildSubject(),
            todosRepository: todosRepository,
          );

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
          await tester.pumpApp(
            buildSubject(),
            todosRepository: todosRepository,
          );

          final todo = mockTodos.first;

          final todoListTile = tester.widget<TodoListTile>(
            find.byType(TodoListTile).first,
          );
          todoListTile.onDismissed!(DismissDirection.startToEnd);

          verify(
            () => todosOverviewBloc.add(TodosOverviewTodoDeleted(todo)),
          ).called(1);
        },
      );

      testWidgets(
        'navigates to EditTodoPage '
        'when TodoListTile.onTap is called',
        (tester) async {
          await tester.pumpApp(
            buildSubject(),
            todosRepository: todosRepository,
          );

          final todoListTile = tester.widget<TodoListTile>(
            find.byType(TodoListTile).first,
          );
          todoListTile.onTap!();

          verify(
            () => navigator.push<void>(any(that: isRoute<void>())),
          ).called(1);
        },
      );
    });
  });
}
