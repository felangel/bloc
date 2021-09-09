part of 'todos_overview_bloc.dart';

abstract class TodosOverviewEvent extends Equatable {
  const TodosOverviewEvent();

  @override
  List<Object> get props => [];
}

class TodosOverviewSubscriptionRequested extends TodosOverviewEvent {
  const TodosOverviewSubscriptionRequested();
}

class TodosOverviewTodoSaved extends TodosOverviewEvent {
  const TodosOverviewTodoSaved(this.todo);

  final Todo todo;

  @override
  List<Object> get props => [todo];
}

class TodosOverviewTodoCompletionToggled extends TodosOverviewEvent {
  const TodosOverviewTodoCompletionToggled({
    required this.todo,
    required this.completed,
  });

  final Todo todo;
  final bool completed;
}

class TodosOverviewTodoDeleted extends TodosOverviewEvent {
  const TodosOverviewTodoDeleted(this.todo);

  final Todo todo;

  @override
  List<Object> get props => [todo];
}

class TodosOverviewUndoDeletionRequested extends TodosOverviewEvent {
  const TodosOverviewUndoDeletionRequested();
}
