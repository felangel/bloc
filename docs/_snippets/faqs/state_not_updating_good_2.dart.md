```dart
MyBloc() {
    on<MyEvent>((event, emit) {
        // always create a new instance of the state you are going to yield
        emit(state.copyWith(property: event.property));
    })
}
```
