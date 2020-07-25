```dart
BlocListener<BlocA, BlocAState>(
  cubit: blocA,
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  child: Container()
)
```
