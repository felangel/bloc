```dart
Future<void> main() async {
  final bloc = CounterBloc();
  final subscription = bloc.stream.listen(print); // 1
  bloc.add(CounterIncrementPresed());
  await Future.delayed(Duration.zero);
  await subscription.cancel();
  await bloc.close();
}
```