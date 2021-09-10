```dart
MyBloc() {
    on<MyEvent>((event, emit) {
        final data = _getData(event.info);
        // always create a new instance of the state you are going to yield
        emit(MyState(data: data));
    })
}
```
