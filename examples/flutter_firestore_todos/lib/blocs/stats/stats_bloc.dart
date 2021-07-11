import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_firestore_todos/blocs/blocs.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  late StreamSubscription _todosSubscription;

  StatsBloc({required TodosBloc todosBloc}) : super(StatsLoading()) {
    on<UpdateStats>(_onUpdateStats);
    final todosState = todosBloc.state;
    if (todosState is TodosLoaded) {
      scheduleMicrotask(() => add(UpdateStats(todosState.todos)));
    }
    _todosSubscription = todosBloc.stream.listen((state) {
      if (state is TodosLoaded) {
        add(UpdateStats(state.todos));
      }
    });
  }

  void _onUpdateStats(UpdateStats event, Emit<StatsState> emit) async {
    if (event is UpdateStats) {
      final numActive =
          event.todos.where((todo) => !todo.complete).toList().length;
      final numCompleted =
          event.todos.where((todo) => todo.complete).toList().length;
      emit(StatsLoaded(numActive, numCompleted));
    }
  }

  @override
  Future<void> close() {
    _todosSubscription.cancel();
    return super.close();
  }
}
