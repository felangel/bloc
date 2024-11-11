state_base_class_suffix
===
severity: WARNING

The base state class should always be suffixed by `State`.

## Example:

❌ **BAD**:

```dart
@immutable
sealed class HomepageData {}

final class HomepageInitial extends HomepageData {}
```

✅ **GOOD**:

```dart
@immutable
sealed class HomepageState {}

final class HomepageInitial extends HomepageState {}
```

## Additional Resources

- [Bloc Library Documentation: Naming Conventions / State Conventions](https://bloclibrary.dev/naming-conventions/#state-conventions)
