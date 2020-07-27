```dart
BlocBuilder<BlocA, BlocAState>(
  cubit: blocA, // provide the local cubit instance
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```
