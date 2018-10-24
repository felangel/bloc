import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/login/login.dart';

class LoginForm extends StatefulWidget {
  final LoginBloc loginBloc;
  final AuthenticationBloc authBloc;

  LoginForm({
    Key key,
    @required this.loginBloc,
    @required this.authBloc,
  }) : super(key: key);

  @override
  State<LoginForm> createState() {
    return LoginFormState(
      loginBloc: loginBloc,
      authBloc: authBloc,
    );
  }
}

class LoginFormState extends State<LoginForm> {
  final LoginBloc loginBloc;
  final AuthenticationBloc authBloc;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  LoginFormState({
    @required this.loginBloc,
    @required this.authBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginEvent, LoginState>(
      bloc: loginBloc,
      builder: (
        BuildContext context,
        LoginState loginState,
      ) {
        if (_loginSucceeded(loginState)) {
          authBloc.onLogin(token: loginState.token);
          loginBloc.onLoginSuccess();
        }

        if (_loginFailed(loginState)) {
          _onWidgetDidBuild(() {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${loginState.error}'),
                backgroundColor: Colors.red,
              ),
            );
          });
        }

        return _form(loginState);
      },
    );
  }

  Widget _form(LoginState loginState) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'username'),
            controller: usernameController,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'password'),
            controller: passwordController,
            obscureText: true,
          ),
          RaisedButton(
            onPressed:
                loginState.isLoginButtonEnabled ? _onLoginButtonPressed : null,
            child: Text('Login'),
          ),
          Container(
            child: loginState.isLoading ? CircularProgressIndicator() : null,
          ),
        ],
      ),
    );
  }

  bool _loginSucceeded(LoginState state) => state.token.isNotEmpty;
  bool _loginFailed(LoginState state) => state.error.isNotEmpty;

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  _onLoginButtonPressed() {
    loginBloc.onLoginButtonPressed(
      username: usernameController.text,
      password: passwordController.text,
    );
  }
}
