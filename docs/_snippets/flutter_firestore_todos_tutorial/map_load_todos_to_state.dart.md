```dart
Stream<TodosState> _mapLoadTodosToState() async* {
  _todosSubscription?.cancel();
  _todosSubscription = _todosRepository.todos().listen(
      (todos) => add(TodosUpdated(todos)),
    );
}
```
