import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_login/app.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  runApp(const FlutterLogin());
}

class FlutterLogin extends StatefulWidget {
  const FlutterLogin({
    super.key,
  });

  @override
  State<FlutterLogin> createState() => _FlutterLoginState();
}

class _FlutterLoginState extends State<FlutterLogin> {
  late AuthenticationRepository authenticationRepository;
  late UserRepository userRepository;
  @override
  void initState() {
    authenticationRepository = AuthenticationRepository();
    userRepository = UserRepository();
    super.initState();
  }

  @override
  void dispose() {
    authenticationRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return App(
      authenticationRepository: authenticationRepository,
      userRepository: userRepository,
    );
  }
}
