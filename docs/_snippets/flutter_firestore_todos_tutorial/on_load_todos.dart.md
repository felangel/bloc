```dart
void _onLoadTodos(LoadTodos event, Emitter<TodosState> emit) {
  _todosSubscription?.cancel();
  _todosSubscription = _todosRepository.todos().listen((todos) {
    add(TodosUpdated(todos));
  });
}
```
