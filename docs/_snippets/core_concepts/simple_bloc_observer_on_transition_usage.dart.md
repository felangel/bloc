```dart
void main() {
  Bloc.observer = SimpleBlocObserver();
  CounterBloc()
    ..add(Increment())
    ..close();
}
```