import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/stats/stats.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  group('StatsBloc', () {
    late TodosRepository todosRepository;

    setUpAll(commonSetUpAll);

    setUp(() {
      todosRepository = MockTodosRepository();
    });

    StatsBloc buildBloc() => StatsBloc(todosRepository: todosRepository);

    group('constructor', () {
      test('works properly', () {
        expect(buildBloc, returnsNormally);
      });

      test('has correct initial state', () {
        expect(
          buildBloc().state,
          equals(const StatsState()),
        );
      });
    });

    group('StatsSubscriptionRequested', () {
      blocTest<StatsBloc, StatsState>(
        'starts listening to repository getTodos stream',
        build: buildBloc,
        act: (bloc) => bloc.add(const StatsSubscriptionRequested()),
        verify: (bloc) {
          verify(() => todosRepository.getTodos()).called(1);
        },
      );

      blocTest<StatsBloc, StatsState>(
        'emits state with updated status, completed todo and active todo count '
        'when repository getTodos stream emits new todos',
        build: buildBloc,
        act: (bloc) => bloc.add(const StatsSubscriptionRequested()),
        expect: () => [
          const StatsState(
            status: StatsStatus.loading,
          ),
          StatsState(
            status: StatsStatus.success,
            completedTodos: mockTodos.where((todo) => todo.isCompleted).length,
            activeTodos: mockTodos.where((todo) => !todo.isCompleted).length,
          ),
        ],
      );

      blocTest<StatsBloc, StatsState>(
        'emits state with failure status '
        'when repository getTodos stream emits error',
        setUp: () {
          when(() => todosRepository.getTodos())
              .thenAnswer((_) => Stream.error(Exception('oops')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const StatsSubscriptionRequested()),
        expect: () => [
          const StatsState(
            status: StatsStatus.loading,
          ),
          const StatsState(
            status: StatsStatus.failure,
          ),
        ],
      );
    });
  });
}
