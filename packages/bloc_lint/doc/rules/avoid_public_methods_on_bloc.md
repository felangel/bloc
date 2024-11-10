avoid_public_method_on_bloc
===
severity: WARNING

Avoid public methods on `Bloc` classes.

## Example:

❌ **BAD**:

```dart
class MyBloc extends Bloc<int, int> {
  MyBloc(super.initialState);

  void test() {}
}
```

✅ **GOOD**:

```dart
class MyBloc extends Bloc<int, int> {
  MyBloc(super.initialState);

  void _test() {}
}
```