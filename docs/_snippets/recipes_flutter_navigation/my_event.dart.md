```dart
import 'package:meta/meta.dart';

@immutable
abstract class MyEvent {}

class EventA extends MyEvent {}

class EventB extends MyEvent {}
```
