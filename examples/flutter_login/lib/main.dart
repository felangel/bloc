import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_login/app.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(AppRoot(authenticationRepository: AuthenticationRepository()));
}
