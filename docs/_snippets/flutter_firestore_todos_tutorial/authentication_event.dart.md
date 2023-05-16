```dart
import 'package:equatable/equatable.dart';

sealed class AuthenticationEvent extends Equatable {}

final class AppStarted extends AuthenticationEvent {
  @override
  List<Object> get props => [];
}
```
