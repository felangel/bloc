```dart
Stream<TodosState> _mapTodosUpdateToState(TodosUpdated event) async* {
  yield TodosLoaded(event.todos);
}
```
