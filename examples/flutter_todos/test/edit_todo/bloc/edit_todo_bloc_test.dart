import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/edit_todo/edit_todo.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

class FakeTodo extends Fake implements Todo {}

void main() {
  group('EditTodoBloc', () {
    late TodosRepository todosRepository;

    setUpAll(() {
      registerFallbackValue(FakeTodo());
    });

    setUp(() {
      todosRepository = MockTodosRepository();
    });

    EditTodoBloc buildBloc() {
      return EditTodoBloc(
        todosRepository: todosRepository,
        initialTodo: null,
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(buildBloc, returnsNormally);
      });

      test('has correct initial state', () {
        expect(
          buildBloc().state,
          equals(const EditTodoState()),
        );
      });
    });

    group('EditTodoTitleChanged', () {
      blocTest<EditTodoBloc, EditTodoState>(
        'emits new state with updated title',
        build: buildBloc,
        act: (bloc) => bloc.add(const EditTodoTitleChanged('newtitle')),
        expect: () => const [
          EditTodoState(title: 'newtitle'),
        ],
      );
    });

    group('EditTodoDescriptionChanged', () {
      blocTest<EditTodoBloc, EditTodoState>(
        'emits new state with updated description',
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const EditTodoDescriptionChanged('newdescription')),
        expect: () => const [
          EditTodoState(description: 'newdescription'),
        ],
      );
    });

    group('EditTodoSubmitted', () {
      blocTest<EditTodoBloc, EditTodoState>(
        'attempts to save new todo to repository '
        'if no initial todo was provided',
        setUp: () {
          when(() => todosRepository.saveTodo(any())).thenAnswer((_) async {});
        },
        build: buildBloc,
        seed: () => const EditTodoState(
          title: 'title',
          description: 'description',
        ),
        act: (bloc) => bloc.add(const EditTodoSubmitted()),
        expect: () => const [
          EditTodoState(
            status: EditTodoStatus.loading,
            title: 'title',
            description: 'description',
          ),
          EditTodoState(
            status: EditTodoStatus.success,
            title: 'title',
            description: 'description',
          ),
        ],
        verify: (bloc) {
          verify(
            () => todosRepository.saveTodo(
              any(
                that: isA<Todo>()
                    .having((t) => t.title, 'title', equals('title'))
                    .having(
                      (t) => t.description,
                      'description',
                      equals('description'),
                    ),
              ),
            ),
          ).called(1);
        },
      );

      blocTest<EditTodoBloc, EditTodoState>(
        'attempts to save updated todo to repository '
        'if an initial todo was provided',
        setUp: () {
          when(() => todosRepository.saveTodo(any())).thenAnswer((_) async {});
        },
        build: buildBloc,
        seed: () => EditTodoState(
          initialTodo: Todo(
            id: 'initial-id',
            title: 'initial-title',
          ),
          title: 'title',
          description: 'description',
        ),
        act: (bloc) => bloc.add(const EditTodoSubmitted()),
        expect: () => [
          EditTodoState(
            status: EditTodoStatus.loading,
            initialTodo: Todo(
              id: 'initial-id',
              title: 'initial-title',
            ),
            title: 'title',
            description: 'description',
          ),
          EditTodoState(
            status: EditTodoStatus.success,
            initialTodo: Todo(
              id: 'initial-id',
              title: 'initial-title',
            ),
            title: 'title',
            description: 'description',
          ),
        ],
        verify: (bloc) {
          verify(
            () => todosRepository.saveTodo(
              any(
                that: isA<Todo>()
                    .having((t) => t.id, 'id', equals('initial-id'))
                    .having((t) => t.title, 'title', equals('title'))
                    .having(
                      (t) => t.description,
                      'description',
                      equals('description'),
                    ),
              ),
            ),
          );
        },
      );

      blocTest<EditTodoBloc, EditTodoState>(
        'emits new state with error if save to repository fails',
        build: () {
          when(() => todosRepository.saveTodo(any()))
              .thenThrow(Exception('oops'));
          return buildBloc();
        },
        seed: () => const EditTodoState(
          title: 'title',
          description: 'description',
        ),
        act: (bloc) => bloc.add(const EditTodoSubmitted()),
        expect: () => const [
          EditTodoState(
            status: EditTodoStatus.loading,
            title: 'title',
            description: 'description',
          ),
          EditTodoState(
            status: EditTodoStatus.failure,
            title: 'title',
            description: 'description',
          ),
        ],
      );
    });
  });
}
