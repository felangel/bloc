```dart
blocTest(
    'emits [1] when CounterIncrementPressed is added',
    build: () => counterBloc,
    act: (bloc) => bloc.add(CounterIncrementPressed()),
    expect: () => [1],
);

blocTest(
    'emits [-1] when CounterDecrementPressed is added',
    build: () => counterBloc,
    act: (bloc) => bloc.add(CounterDecrementPressed()),
    expect: () => [-1],
);
```
