```dart
void main() {
  Bloc.observer = SimpleBlocObserver();
  CounterBloc()
    ..add(CounterIncremented())
    ..close();
}
```