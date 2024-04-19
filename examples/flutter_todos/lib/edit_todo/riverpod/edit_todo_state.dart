import 'package:todos_repository/todos_repository.dart';

enum EditTodoStatus { initial, loading, success, failure }

extension EditTodoStatusX on EditTodoStatus {
  bool get isLoadingOrSuccess =>
      this == EditTodoStatus.loading || this == EditTodoStatus.success;
}

class EditTodoState {
  const EditTodoState({
    this.status = EditTodoStatus.initial,
    this.initialTodo,
    this.title = '',
    this.description = '',
  });

  final EditTodoStatus status;
  final Todo? initialTodo;
  final String title;
  final String description;

  bool get isNewTodo => initialTodo == null;

  EditTodoState copyWith({
    EditTodoStatus? status,
    Todo? initialTodo,
    String? title,
    String? description,
  }) =>
      EditTodoState(
        status: status ?? this.status,
        initialTodo: initialTodo ?? this.initialTodo,
        title: title ?? this.title,
        description: description ?? this.description,
      );
}
