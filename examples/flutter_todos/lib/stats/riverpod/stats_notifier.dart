import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/bootstrap.dart';
import 'package:flutter_todos/stats/riverpod/stats_state.dart';
import 'package:todos_repository/todos_repository.dart';

final statsNotifierProvider = StateNotifierProvider<StatsNotifier, StatsState>(
  (ref) => StatsNotifier(ref.read(todosRepositoryProvider)),
);

class StatsNotifier extends StateNotifier<StatsState> {
  StatsNotifier(this._todosRepository) : super(const StatsState());

  final TodosRepository _todosRepository;

  Future<void> fetchStats() async {
    state = state.copyWith(status: StatsStatus.loading);

    try {
      final todos = await _todosRepository.getTodos().first;
      state = state.copyWith(
        status: StatsStatus.success,
        completedTodos: todos.where((todo) => todo.isCompleted).length,
        activeTodos: todos.where((todo) => !todo.isCompleted).length,
      );
    } catch (e) {
      state = state.copyWith(status: StatsStatus.failure);
    }
  }
}
