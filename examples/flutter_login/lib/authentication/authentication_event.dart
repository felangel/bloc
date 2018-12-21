import 'package:meta/meta.dart';

abstract class AuthenticationEvent {}

class AppStart extends AuthenticationEvent {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppStart && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AppStart';
}

class Login extends AuthenticationEvent {
  final String token;

  Login({@required this.token});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Login &&
          runtimeType == other.runtimeType &&
          token == other.token;

  @override
  int get hashCode => token.hashCode;

  @override
  String toString() => 'Login { token: $token }';
}

class Logout extends AuthenticationEvent {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Logout && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Logout';
}
