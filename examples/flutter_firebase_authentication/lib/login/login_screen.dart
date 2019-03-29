import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_authentication/login/login.dart';

class LoginScreen extends StatelessWidget {
  final LoginBloc _loginBloc;

  LoginScreen({@required LoginBloc loginBloc})
      : assert(loginBloc != null),
        _loginBloc = loginBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: BlocProvider(
          bloc: _loginBloc,
          child: LoginButton(),
        ),
      ),
    );
  }
}
