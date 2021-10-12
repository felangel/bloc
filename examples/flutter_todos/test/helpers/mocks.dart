import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_todos/edit_todo/edit_todo.dart';
import 'package:flutter_todos/home/home.dart';
import 'package:flutter_todos/stats/stats.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

final mockTodos = [
  Todo(
    id: '1',
    title: 'title 1',
    description: 'description 1',
  ),
  Todo(
    id: '2',
    title: 'title 2',
    description: 'description 2',
  ),
  Todo(
    id: '3',
    title: 'title 3',
    description: 'description 3',
    isCompleted: true,
  ),
];

class MockTodosRepository extends Mock implements TodosRepository {
  MockTodosRepository() {
    when(getTodos).thenAnswer((_) => Stream.value(mockTodos));
    when(() => saveTodo(any())).thenAnswer((_) async {});
    when(() => deleteTodo(any())).thenAnswer((_) async {});
    when(clearCompleted).thenAnswer(
      (_) async => mockTodos.where((todo) => !todo.isCompleted).length,
    );
    when(() => completeAll(captureAny())).thenAnswer(
      (i) async => mockTodos
          .where((todo) => todo.isCompleted != i.positionalArguments.first)
          .length,
    );
  }
}

class FakeTodo extends Fake implements Todo {}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {
  MockHomeCubit() {
    when(() => state).thenReturn(const HomeState());
  }
}

class MockHomeState extends Mock implements HomeState {}

class MockTodosOverviewBloc
    extends MockBloc<TodosOverviewEvent, TodosOverviewState>
    implements TodosOverviewBloc {
  MockTodosOverviewBloc() {
    when(() => state).thenReturn(TodosOverviewState(
      status: TodosOverviewStatus.success,
      todos: mockTodos,
    ));
  }
}

class MockTodosOverviewEvent extends Mock implements TodosOverviewEvent {}

class MockTodosOverviewState extends Mock implements TodosOverviewState {}

class MockEditTodoBloc extends MockBloc<EditTodoEvent, EditTodoState>
    implements EditTodoBloc {
  MockEditTodoBloc() {
    when(() => state).thenReturn(EditTodoState(
      initialTodo: mockTodos.first,
      title: mockTodos.first.title,
      description: mockTodos.first.description,
    ));
  }
}

class MockEditTodoEvent extends Mock implements EditTodoEvent {}

class MockEditTodoState extends Mock implements EditTodoState {}

class MockStatsBloc extends MockBloc<StatsEvent, StatsState>
    implements StatsBloc {
  MockStatsBloc() {
    when(() => state).thenReturn(StatsState(
      status: StatsStatus.success,
      completedTodos: mockTodos.where((todo) => todo.isCompleted).length,
      activeTodos: mockTodos.where((todo) => !todo.isCompleted).length,
    ));
  }
}

class MockStatsEvent extends Mock implements StatsEvent {}

class MockStatsState extends Mock implements StatsState {}
