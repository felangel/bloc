```dart
void _onTodosUpdated(TodosUpdated event, Emitter<TodosState> emit) {
  emit(TodosLoaded(event.todos));
}
```
