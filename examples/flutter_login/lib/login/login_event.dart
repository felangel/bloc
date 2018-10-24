import 'package:meta/meta.dart';

import 'package:flutter/widgets.dart';

abstract class LoginEvent {}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  LoginButtonPressed({
    @required this.username,
    @required this.password,
  });
}

class LoggedIn extends LoginEvent {}
