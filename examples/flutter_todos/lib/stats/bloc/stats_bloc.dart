import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todos_repository/todos_repository.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({
    required TodosRepository todosRepository,
  }) : _todosRepository = todosRepository,
       super(const StatsState()) {
    on<StatsSubscriptionRequested>(_onSubscriptionRequested);
  }

  final TodosRepository _todosRepository;

  Future<void> _onSubscriptionRequested(
    StatsSubscriptionRequested event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(status: StatsStatus.loading));

    await emit.forEach<List<Todo>>(
      _todosRepository.getTodos(),
      onData: (todos) => state.copyWith(
        status: StatsStatus.success,
        completedTodos: todos.where((todo) => todo.isCompleted).length,
        activeTodos: todos.where((todo) => !todo.isCompleted).length,
      ),
      onError: (_, _) => state.copyWith(status: StatsStatus.failure),
    );
  }
}
