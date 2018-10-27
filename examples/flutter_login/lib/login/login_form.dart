import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/login/login.dart';

class LoginForm extends StatefulWidget {
  final LoginBloc _loginBloc;
  final AuthenticationBloc _authBloc;

  LoginForm({
    Key key,
    @required LoginBloc loginBloc,
    @required AuthenticationBloc authBloc,
  })  : _loginBloc = loginBloc,
        _authBloc = authBloc,
        super(key: key);

  @override
  State<LoginForm> createState() {
    return LoginFormState(
      loginBloc: _loginBloc,
      authBloc: _authBloc,
    );
  }
}

class LoginFormState extends State<LoginForm> {
  final LoginBloc _loginBloc;
  final AuthenticationBloc _authBloc;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginFormState({
    @required LoginBloc loginBloc,
    @required AuthenticationBloc authBloc,
  })  : _loginBloc = loginBloc,
        _authBloc = authBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginEvent, LoginState>(
      bloc: _loginBloc,
      builder: (
        BuildContext context,
        LoginState loginState,
      ) {
        if (_loginSucceeded(loginState)) {
          _authBloc.onLogin(token: loginState.token);
          _loginBloc.onLoginSuccess();
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
            controller: _usernameController,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'password'),
            controller: _passwordController,
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
    _loginBloc.onLoginButtonPressed(
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }
}
