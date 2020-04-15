```dart
blocTest(
    '...',
    build: () => MyBloc(),
    act: (bloc) => bloc.add(MyEvent()),
    expect: [
        isA<MyStateA>(),
        isA<MyStateB>(),
    ],
)
```
