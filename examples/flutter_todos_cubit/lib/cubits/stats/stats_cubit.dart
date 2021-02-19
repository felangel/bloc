import 'dart:async';
import 'package:flutter_todos_cubit/models/todo.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_todos_cubit/cubits/cubits.dart';

class StatsCubit extends Cubit<StatsState> {
  final TodosCubit todosCubit;
  StreamSubscription todosSubscription;

  StatsCubit({@required this.todosCubit}) : super(StatsLoadInProgress()) {
    void onTodosStateChanged(state) {
      if (state is TodosLoadSuccess) {
        statsUpdated(state.todos);
      }
    }

    onTodosStateChanged(todosCubit.state);
    todosSubscription = todosCubit.listen(onTodosStateChanged);
  }

  Future<void> statsUpdated(final List<Todo> todos) async {
    final numActive =
        todos.where((_) => !_.complete).toList().length;
    final numCompleted =
        todos.where((_) => _.complete).toList().length;
    emit(StatsLoadSuccess(numActive, numCompleted));
  }

  @override
  Future<void> close() {
    todosSubscription.cancel();
    return super.close();
  }
}
