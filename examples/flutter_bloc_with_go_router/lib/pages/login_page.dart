import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/authentication_bloc.dart';
import '../bloc/authentication_event.dart';
import '../type/authentication_status_type.dart';

/// after login, home page will show user's info
class LoginPage extends StatefulWidget {
  /// Creates an [HomePage].
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('please click under button, if you want to sign in.'),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                const AuthenticationStatusChanged event =
                    AuthenticationStatusChanged(
                        AuthenticationStatusType.authenticated);
                context.read<AuthenticationBloc>().add(event);
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
