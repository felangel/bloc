```dart
void main() {
  BlocOverrides.runZoned(
    () {
      CounterBloc()
        ..add(CounterIncrementPressed())
        ..close();
    },
    blocObserver: SimpleBlocObserver(),
  );
}
```
