```dart
MyBloc() {
    on<MyEvent>((event, emit) {
        // never modify/mutate state
        state.property = event.property;
        // never emit the same instance of state
        emit(state);
    })
}
```
