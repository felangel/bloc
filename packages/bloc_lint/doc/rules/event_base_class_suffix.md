event_base_class_suffix
===
exists from: 0.1.0

severity: WARNING

The base event class should always be suffixed by `Event`.

## Example:

❌ **BAD**:

```dart
@immutable
sealed class CounterData {}

final class CounterStarted extends CounterData {}
```

✅ **GOOD**:

```dart
@immutable
sealed class CounterEvent {}

final class CounterStarted extends CounterEvent {}
```

## Additional Resources

- [Bloc Library Documentation: Naming Conventions / Event Conventions](https://bloclibrary.dev/naming-conventions/#event-conventions)
