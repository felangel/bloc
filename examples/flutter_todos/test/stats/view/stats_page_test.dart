import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/stats/stats.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  setUpAll(commonSetUpAll);

  group('StatsPage', () {
    late TodosRepository todosRepository;

    setUp(() {
      todosRepository = MockTodosRepository();
    });

    testWidgets('renders StatsView', (tester) async {
      await tester.pumpApp(
        const StatsPage(),
      );

      expect(find.byType(StatsView), findsOneWidget);
    });

    testWidgets(
      'subscribes to todos from repository on initialization',
      (tester) async {
        await tester.pumpApp(
          const StatsPage(),
          todosRepository: todosRepository,
        );

        verify(() => todosRepository.getTodos()).called(1);
      },
    );
  });

  group('StatsView', () {
    const completedTodosListTileKey = Key('statsView_completedTodos_listTile');
    const activeTodosListTileKey = Key('statsView_activeTodos_listTile');

    late MockNavigator navigator;
    late StatsBloc statsBloc;

    setUp(() {
      navigator = MockNavigator();
      when(() => navigator.push(any())).thenAnswer((_) async {});

      statsBloc = MockStatsBloc();
      when(() => statsBloc.state).thenReturn(
        StatsState(
          status: StatsStatus.success,
          completedTodos: mockTodos.where((todo) => todo.isCompleted).length,
          activeTodos: mockTodos.where((todo) => !todo.isCompleted).length,
        ),
      );
    });

    Widget buildSubject() {
      return MockNavigatorProvider(
        navigator: navigator,
        child: BlocProvider.value(
          value: statsBloc,
          child: const StatsView(),
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
            matching: find.text(l10n.statsAppBarTitle),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders completed todos ListTile '
      'with correct icon, label and value',
      (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.byKey(completedTodosListTileKey), findsOneWidget);

        expect(
          find.descendant(
            of: find.byKey(completedTodosListTileKey),
            matching: find.text(l10n.statsCompletedTodoCountLabel),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: find.byKey(completedTodosListTileKey),
            matching: find.byIcon(Icons.check_rounded),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: find.byKey(completedTodosListTileKey),
            matching: find.text(
              mockTodos.where((todo) => todo.isCompleted).length.toString(),
            ),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders active todos ListTile '
      'with correct icon, label and value',
      (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.byKey(activeTodosListTileKey), findsOneWidget);

        expect(
          find.descendant(
            of: find.byKey(activeTodosListTileKey),
            matching: find.text(l10n.statsActiveTodoCountLabel),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: find.byKey(activeTodosListTileKey),
            matching: find.byIcon(Icons.radio_button_unchecked_rounded),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: find.byKey(activeTodosListTileKey),
            matching: find.text(
              mockTodos.where((todo) => !todo.isCompleted).length.toString(),
            ),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
