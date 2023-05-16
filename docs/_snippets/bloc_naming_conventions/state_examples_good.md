```dart
sealed class CounterState {}
final class CounterInitial extends CounterState {}
final class CounterLoadInProgress extends CounterState {}
final class CounterLoadSuccess extends CounterState {}
final class CounterLoadFailure extends CounterState {}
```
