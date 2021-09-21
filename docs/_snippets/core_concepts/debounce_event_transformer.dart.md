```dart
EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

CounterBloc() : super(0) {
  on<Increment>(
    (event, emit) => emit(state + 1),
    /// Apply the custom `EventTransformer` to the `EventHandler`.
    transformer: debounce(const Duration(milliseconds: 300)),
  );
}
```