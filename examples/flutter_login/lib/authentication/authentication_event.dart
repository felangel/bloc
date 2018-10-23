import 'package:meta/meta.dart';

abstract class AuthenticationEvent {}

class AppStart extends AuthenticationEvent {}

class AuthenticationSuccess extends AuthenticationEvent {
  final String token;

  AuthenticationSuccess({@required this.token});
}

class LogoutPressed extends AuthenticationEvent {}
