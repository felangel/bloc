```dart
group('CounterBloc', () {
    late CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });

    test('initial state is 0', () {
        expect(counterBloc.state, 0);
    });
});
```
