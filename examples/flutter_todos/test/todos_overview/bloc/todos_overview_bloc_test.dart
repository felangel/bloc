import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TodosOverviewBloc', () {
    late TodosRepository todosRepository;

    setUpAll(commonSetUpAll);

    setUp(() {
      todosRepository = MockTodosRepository();
    });

    TodosOverviewBloc buildBloc() =>
        TodosOverviewBloc(todosRepository: todosRepository);

    group('constructor', () {
      test('works properly', () {
        expect(buildBloc, returnsNormally);
      });

      test('has correct initial state', () {
        expect(
          buildBloc().state,
          equals(const TodosOverviewState()),
        );
      });
    });

    group('TodosOverviewSubscriptionRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'starts listening to repository getTodos stream',
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewSubscriptionRequested()),
        verify: (bloc) {
          verify(() => todosRepository.getTodos()).called(1);
        },
      );

      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'emits state with updated status and todos '
        'when repository getTodos stream emits new todos',
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewSubscriptionRequested()),
        expect: () => [
          const TodosOverviewState(
            status: TodosOverviewStatus.loading,
          ),
          TodosOverviewState(
            status: TodosOverviewStatus.success,
            todos: mockTodos,
          ),
        ],
      );

      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'emits state with failure status '
        'when repository getTodos stream emits error',
        setUp: () {
          when(() => todosRepository.getTodos())
              .thenAnswer((_) => Stream.error(Exception('oops')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewSubscriptionRequested()),
        expect: () => [
          const TodosOverviewState(
            status: TodosOverviewStatus.loading,
          ),
          const TodosOverviewState(
            status: TodosOverviewStatus.failure,
          ),
        ],
      );
    });

    group('TodosOverviewTodoSaved', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'saves todo using repository',
        build: buildBloc,
        act: (bloc) => bloc.add(TodosOverviewTodoSaved(mockTodos.first)),
        verify: (bloc) {
          verify(() => todosRepository.saveTodo(mockTodos.first)).called(1);
        },
      );
    });

    group('TodosOverviewTodoCompletionToggled', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'saves todo with isCompleted set to event isCompleted flag',
        build: buildBloc,
        seed: () => TodosOverviewState(
          todos: mockTodos,
        ),
        act: (bloc) => bloc.add(
          TodosOverviewTodoCompletionToggled(
            todo: mockTodos.first,
            isCompleted: true,
          ),
        ),
        verify: (bloc) {
          verify(
            () => todosRepository.saveTodo(
              mockTodos.first.copyWith(isCompleted: true),
            ),
          ).called(1);
        },
      );
    });

    group('TodosOverviewTodoDeleted', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'deletes todo using repository',
        build: buildBloc,
        seed: () => TodosOverviewState(
          todos: mockTodos,
        ),
        act: (bloc) => bloc.add(TodosOverviewTodoDeleted(mockTodos.first)),
        verify: (bloc) {
          verify(() => todosRepository.deleteTodo(mockTodos.first.id))
              .called(1);
        },
      );
    });

    group('TodosOverviewUndoDeletionRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'restores last deleted undo and clears lastDeletedUndo field',
        build: buildBloc,
        seed: () => TodosOverviewState(
          lastDeletedTodo: mockTodos.first,
        ),
        act: (bloc) => bloc.add(const TodosOverviewUndoDeletionRequested()),
        expect: () => const [
          TodosOverviewState(),
        ],
        verify: (bloc) {
          verify(() => todosRepository.saveTodo(mockTodos.first)).called(1);
        },
      );
    });

    group('TodosOverviewFilterChanged', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'emits state with updated filter',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const TodosOverviewFilterChanged(TodosViewFilter.completedOnly),
        ),
        expect: () => const [
          TodosOverviewState(
            filter: TodosViewFilter.completedOnly,
          ),
        ],
      );
    });

    group('TodosOverviewToggleAllRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'toggles all todos to completed when some or none are uncompleted',
        build: buildBloc,
        seed: () => TodosOverviewState(
          todos: mockTodos,
        ),
        act: (bloc) => bloc.add(const TodosOverviewToggleAllRequested()),
        verify: (bloc) {
          verify(
            () => todosRepository.completeAll(isCompleted: true),
          ).called(1);
        },
      );

      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'toggles all todos to uncompleted when all are completed',
        build: buildBloc,
        seed: () => TodosOverviewState(
          todos: mockTodos
              .map((todo) => todo.copyWith(isCompleted: true))
              .toList(),
        ),
        act: (bloc) => bloc.add(const TodosOverviewToggleAllRequested()),
        verify: (bloc) {
          verify(
            () => todosRepository.completeAll(isCompleted: false),
          ).called(1);
        },
      );
    });

    group('TodosOverviewClearCompletedRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'clears completed todos using repository',
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewClearCompletedRequested()),
        verify: (bloc) {
          verify(() => todosRepository.clearCompleted()).called(1);
        },
      );
    });
  });
}
