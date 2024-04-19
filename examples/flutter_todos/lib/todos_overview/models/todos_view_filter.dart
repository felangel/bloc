import 'package:todos_repository/todos_repository.dart';

enum TodosViewFilter { all, activeOnly, completedOnly }

extension TodosViewFilterX on TodosViewFilter {
  bool apply(Todo todo) => switch (this) {
        TodosViewFilter.all => true,
        TodosViewFilter.activeOnly => !todo.isCompleted,
        TodosViewFilter.completedOnly => todo.isCompleted
      };

  Iterable<Todo> applyAll(Iterable<Todo> todos) => todos.where(apply);
}
