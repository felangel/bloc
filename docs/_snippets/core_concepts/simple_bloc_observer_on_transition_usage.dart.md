```dart
void main() {
  BlocOverrides.runZoned(
    () {
      CounterBloc()
        ..add(Increment())
        ..close();
    },
    blocObserver: SimpleBlocObserver(),
  );
}
```
