```dart
import 'package:meta/meta.dart';

@immutable
sealed class MyState {}

final class StateA extends MyState {}

final class StateB extends MyState {}
```
