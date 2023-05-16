```dart
import 'package:meta/meta.dart';

@immutable
sealed class DataState {}

final class Initial extends DataState {}

final class Loading extends DataState {}

final class Success extends DataState {}
```
