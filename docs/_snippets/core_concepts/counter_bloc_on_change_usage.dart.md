```dart
void main() {
  CounterBloc()
    ..add(CounterIncremented())
    ..close();
}
```