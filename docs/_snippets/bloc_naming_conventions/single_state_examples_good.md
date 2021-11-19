```dart
enum CounterStatus { initial, loading, success, failure }
class CounterState {
  const CounterState({this.status = CounterStatus.initial});
  final CounterStatus status;
}
```
