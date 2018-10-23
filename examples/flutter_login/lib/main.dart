import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/splash/splash.dart';
import 'package:flutter_login/login/login.dart';
import 'package:flutter_login/home/home.dart';

void main() {
  final loginBloc = LoginBloc();
  final authenticationBloc = AuthenticationBloc();

  runApp(App(
    loginBloc: loginBloc,
    authenticationBloc: authenticationBloc,
  ));
}

class App extends StatelessWidget {
  final LoginBloc loginBloc;
  final AuthenticationBloc authenticationBloc;

  const App({
    Key key,
    @required this.loginBloc,
    @required this.authenticationBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    authenticationBloc.onAppStart();

    return BlocProvider<AuthenticationBloc>(
      bloc: authenticationBloc,
      child: MaterialApp(
        home: _rootPage(),
      ),
    );
  }

  Widget _rootPage() {
    return BlocBuilder<AuthenticationEvent, AuthenticationState>(
      bloc: authenticationBloc,
      builder: (BuildContext context, AuthenticationState authState) {
        List<Widget> _widgets = [];

        if (authState.isAuthenticated) {
          _widgets.add(HomePage());
        } else {
          _widgets.add(_loginPage());
        }

        if (authState.isInitializing) {
          _widgets.add(SplashPage());
        }

        if (authState.isLoading) {
          _widgets.add(_loadingIndicator());
        }

        return Stack(
          children: _widgets,
        );
      },
    );
  }

  Widget _loginPage() {
    return BlocProvider<LoginBloc>(
      bloc: loginBloc,
      child: LoginPage(),
    );
  }

  Widget _loadingIndicator() {
    return Stack(
      children: [
        Opacity(
          opacity: 0.3,
          child: const ModalBarrier(dismissible: false, color: Colors.grey),
        ),
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}
