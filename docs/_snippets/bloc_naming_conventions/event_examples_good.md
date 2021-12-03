```dart
abstract class CounterEvent {}
class CounterStarted extends CounterEvent {}
class CounterIncrementPressed extends CounterEvent {}
class CounterDecrementPressed extends CounterEvent {}
class CounterIncrementRetried extends CounterEvent {}
```
