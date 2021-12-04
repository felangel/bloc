import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/stats/stats.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

void main() {
  final todo = Todo(
    id: '1',
    title: 'title 1',
    description: 'description 1',
  );

  group('StatsBloc', () {
    late TodosRepository todosRepository;

    setUp(() {
      todosRepository = MockTodosRepository();
      when(todosRepository.getTodos).thenAnswer((_) => const Stream.empty());
    });

    StatsBloc buildBloc() => StatsBloc(todosRepository: todosRepository);

    group('constructor', () {
      test('works properly', () {
        expect(buildBloc, returnsNormally);
      });

      test('has correct initial state', () {
        expect(buildBloc().state, equals(const StatsState()));
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
        setUp: () {
          when(
            todosRepository.getTodos,
          ).thenAnswer((_) => Stream.value([todo]));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const StatsSubscriptionRequested()),
        expect: () => [
          const StatsState(status: StatsStatus.loading),
          const StatsState(
            status: StatsStatus.success,
            activeTodos: 1,
          ),
        ],
      );

      blocTest<StatsBloc, StatsState>(
        'emits state with failure status '
        'when repository getTodos stream emits error',
        setUp: () {
          when(
            () => todosRepository.getTodos(),
          ).thenAnswer((_) => Stream.error(Exception('oops')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const StatsSubscriptionRequested()),
        expect: () => [
          const StatsState(status: StatsStatus.loading),
          const StatsState(status: StatsStatus.failure),
        ],
      );
    });
  });
}
