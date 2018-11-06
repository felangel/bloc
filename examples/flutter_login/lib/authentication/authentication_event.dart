import 'package:meta/meta.dart';

abstract class AuthenticationEvent {}

class AppStarted extends AuthenticationEvent {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppStarted && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AppStarted';
}

class LoggedIn extends AuthenticationEvent {
  final String token;

  LoggedIn({@required this.token});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoggedIn &&
          runtimeType == other.runtimeType &&
          token == other.token;

  @override
  int get hashCode => token.hashCode;

  @override
  String toString() => 'LoggedIn { token: $token }';
}

class LoggedOut extends AuthenticationEvent {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoggedOut && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'LoggedOut';
}
