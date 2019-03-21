import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  AuthenticationEvent([List props = const []]) : super(props);
}

class AppStarted extends AuthenticationEvent {
  @override
  String toString() => 'AppStarted';
}

class Login extends AuthenticationEvent {
  @override
  String toString() => 'LoggedIn';
}

class Logout extends AuthenticationEvent {
  @override
  String toString() => 'LoggedOut';
}
