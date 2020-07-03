```dart
void main() {
  Bloc.observer = SimpleBlocObserver();
  CounterBloc bloc = CounterBloc();

  for (int i = 0; i < 3; i++) {
    bloc.add(CounterEvent.increment);
  }
}
```