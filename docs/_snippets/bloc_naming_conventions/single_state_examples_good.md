```dart
enum CounterStatus { initial, inProgress, success, failure }
class CounterState {
  const CounterState({this.status = CounterStatus.initial});
  final CounterStatus status;
}
```
