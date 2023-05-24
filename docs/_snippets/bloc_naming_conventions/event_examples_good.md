```dart
sealed class CounterEvent {}
final class CounterStarted extends CounterEvent {}
final class CounterIncrementPressed extends CounterEvent {}
final class CounterDecrementPressed extends CounterEvent {}
final class CounterIncrementRetried extends CounterEvent {}
```
