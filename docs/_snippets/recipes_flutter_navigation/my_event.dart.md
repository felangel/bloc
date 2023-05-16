```dart
import 'package:meta/meta.dart';

@immutable
sealed class MyEvent {}

final class EventA extends MyEvent {}

final class EventB extends MyEvent {}
```
