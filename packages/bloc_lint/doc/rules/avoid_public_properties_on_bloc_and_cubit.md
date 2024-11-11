avoid_public_properties_on_bloc_and_cubit
===
exists from: 0.1.0

severity: WARNING

Avoid public properties on `Bloc` and `Cubit`, prefer emit state or use private value.

## Example:

❌ **BAD**:

```dart
class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  int value = 1;
}
```

✅ **GOOD**:
```dart
class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  void init() {
    emit(1);
  }
}
```

or

```dart
class MyCubit extends Cubit<int> {
  MyCubit() : super(0);

  int _value = 1;
}
```
