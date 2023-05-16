```dart
enum CounterStatus { initial, loading, success, failure }
final class CounterState {
  const CounterState({this.status = CounterStatus.initial});
  final CounterStatus status;
}
```
