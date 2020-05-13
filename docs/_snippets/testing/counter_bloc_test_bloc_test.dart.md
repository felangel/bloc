```dart
blocTest(
    'emits [1] when CounterEvent.increment is added',
    build: () async => counterBloc,
    act: (bloc) async => bloc.add(CounterEvent.increment),
    expect: [1],
);

blocTest(
    'emits [-1] when CounterEvent.decrement is added',
    build: () async => counterBloc,
    act: (bloc) async => bloc.add(CounterEvent.decrement),
    expect: [-1],
);
```
