import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/bootstrap.dart';
import 'package:flutter_todos/edit_todo/riverpod/edit_todo_state.dart';
import 'package:uuid/uuid.dart';
// ignore: directives_ordering
import 'package:todos_repository/todos_repository.dart';

final editTodoNotifierProvider =
    StateNotifierProvider.autoDispose<EditTodoNotifier, EditTodoState>(
  (ref) => EditTodoNotifier(
    ref.read(todosRepositoryProvider),
    null,
  ),
);

class EditTodoNotifier extends StateNotifier<EditTodoState> {
  EditTodoNotifier(
    this.todosRepository,
    this.initialTodo,
  ) : super(const EditTodoState());

  final TodosRepository todosRepository;
  final Todo? initialTodo;

  void titleChanged(String title) => state = state.copyWith(title: title);

  void descriptionChanged(String description) => state = state.copyWith(
        description: description,
      );

  Future<void> submit() async {
    state = state.copyWith(status: EditTodoStatus.loading);
    try {
      final todo =
          (initialTodo ?? Todo(id: const Uuid().v4(), title: '')).copyWith(
        title: state.title,
        description: state.description,
      );
      await todosRepository.saveTodo(todo);
      state = state.copyWith(status: EditTodoStatus.success);
    } catch (e) {
      state = state.copyWith(status: EditTodoStatus.failure);
    }
  }
}
