```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    final data = _getData(event.info);
    // always create a new instance of the state you are going to yield
    yield MyState(data: data);
}
```
