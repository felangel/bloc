```dart
blocTest(
    'emits [1] when CounterEvent.increment is added',
    build: () => counterBloc,
    act: (bloc) => bloc.add(Increment()),
    expect: () => [1],
);

blocTest(
    'emits [-1] when CounterEvent.decrement is added',
    build: () => counterBloc,
    act: (bloc) => bloc.add(Decrement()),
    expect: () => [-1],
);
```
