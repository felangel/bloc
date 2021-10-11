import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

part 'edit_todo_event.dart';
part 'edit_todo_state.dart';

class EditTodoBloc extends Bloc<EditTodoEvent, EditTodoState> {
  EditTodoBloc({
    required TodosRepository todosRepository,
    required Todo? initialTodo,
  })  : _todosRepository = todosRepository,
        super(EditTodoState(
          initialTodo: initialTodo,
          title: initialTodo?.title ?? '',
          description: initialTodo?.description ?? '',
        )) {
    on<EditTodoTitleChanged>((event, emit) {
      emit(state.copyWith(title: event.title));
    });

    on<EditTodoDescriptionChanged>((event, emit) {
      emit(state.copyWith(description: event.description));
    });

    on<EditTodoSubmitted>((event, emit) async {
      emit(state.copyWith(status: EditTodoStatus.loading));
      final todo = (state.initialTodo ?? Todo(title: '')).copyWith(
        title: state.title,
        description: state.description,
      );

      try {
        await _todosRepository.saveTodo(todo);
        emit(state.copyWith(status: EditTodoStatus.success));
      } catch (e) {
        emit(state.copyWith(status: EditTodoStatus.failure));
      }
    });
  }

  final TodosRepository _todosRepository;
}
