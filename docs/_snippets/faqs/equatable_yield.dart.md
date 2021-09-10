```dart
MyBloc() {
    on<MyEvent>((event, emit) {
        emit(StateA('hi'));
        emit(StateA('hi'));
    })
}
```
