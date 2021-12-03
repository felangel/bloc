```dart
Future<void> main() async {
  final bloc = CounterBloc();
  print(bloc.state); // 0
  bloc.add(CounterIncrementPressed());
  await Future.delayed(Duration.zero);
  print(bloc.state); // 1
  await bloc.close();
}
```