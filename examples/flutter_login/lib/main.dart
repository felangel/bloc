import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_login/app.dart';
import 'package:flutter/widgets.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  runApp(AppRoot(
    authenticationRepository: AuthenticationRepository(),
    userRepository: UserRepository(),
  ));
}
