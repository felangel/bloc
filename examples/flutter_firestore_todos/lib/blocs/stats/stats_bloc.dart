import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_firestore_todos/blocs/blocs.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  late StreamSubscription _todosSubscription;

  StatsBloc({required TodosBloc todosBloc}) : super(StatsLoading()) {
    final todosState = todosBloc.state;
    if (todosState is TodosLoaded) add(StatsUpdated(todosState.todos));
    _todosSubscription = todosBloc.stream.listen((state) {
      if (state is TodosLoaded) {
        add(StatsUpdated(state.todos));
      }
    });
  }

  @override
  Stream<StatsState> mapEventToState(StatsEvent event) async* {
    if (event is StatsUpdated) {
      final numActive =
          event.todos.where((todo) => !todo.complete).toList().length;
      final numCompleted =
          event.todos.where((todo) => todo.complete).toList().length;
      yield StatsLoaded(numActive, numCompleted);
    }
  }

  @override
  Future<void> close() {
    _todosSubscription.cancel();
    return super.close();
  }
}
