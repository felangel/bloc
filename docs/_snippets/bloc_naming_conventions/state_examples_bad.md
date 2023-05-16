```dart
sealed class CounterState {}
final class Initial extends CounterState {}
final class Loading extends CounterState {}
final class Success extends CounterState {}
final class Succeeded extends CounterState {}
final class Loaded extends CounterState {}
final class Failure extends CounterState {}
final class Failed extends CounterState {}
```
