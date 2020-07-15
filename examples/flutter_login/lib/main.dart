import 'package:flutter/widgets.dart';
import 'package:flutter_login/app.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  runApp(AppRoot(userRepository: UserRepository()));
}
