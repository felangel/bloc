```dart
import 'package:meta/meta.dart';

@immutable
sealed class DataEvent {}

final class FetchData extends DataEvent {}
```
