import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_firestore_todos/blocs/blocs.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  late StreamSubscription _todosSubscription;

  StatsBloc({required TodosBloc todosBloc}) : super(StatsLoading()) {
    on<StatsUpdated>(_onStatsUpdated);
    final todosState = todosBloc.state;
    if (todosState is TodosLoaded) add(StatsUpdated(todosState.todos));
    _todosSubscription = todosBloc.stream.listen((state) {
      if (state is TodosLoaded) {
        add(StatsUpdated(state.todos));
      }
    });
  }

  void _onStatsUpdated(StatsUpdated event, Emitter<StatsState> emit) async {
    final numActive =
        event.todos.where((todo) => !todo.complete).toList().length;
    final numCompleted =
        event.todos.where((todo) => todo.complete).toList().length;
    emit(StatsLoaded(numActive, numCompleted));
  }

  @override
  Future<void> close() {
    _todosSubscription.cancel();
    return super.close();
  }
}
