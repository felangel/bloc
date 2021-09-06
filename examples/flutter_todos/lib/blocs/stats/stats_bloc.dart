import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_todos/blocs/blocs.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final TodosBloc todosBloc;
  StreamSubscription todosSubscription;

  StatsBloc({@required this.todosBloc}) : super(StatsLoadInProgress()) {
    _onTodosStateChanged(todosBloc.state);
    todosSubscription = todosBloc.stream.listen(_onTodosStateChanged);

    on<StatsUpdated>(_onStatsUpdated);
  }

  void _onTodosStateChanged(TodosState state) {
    if (state is TodosLoadSuccess) add(StatsUpdated(state.todos));
  }

  void _onStatsUpdated(StatsUpdated event, Emitter emit) {
    final numActive =
        event.todos.where((todo) => !todo.complete).toList().length;
    final numCompleted =
        event.todos.where((todo) => todo.complete).toList().length;
    emit(StatsLoadSuccess(numActive, numCompleted));
  }

  @override
  Future<void> close() {
    todosSubscription.cancel();
    return super.close();
  }
}
