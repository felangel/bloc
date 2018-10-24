import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/splash/splash.dart';
import 'package:flutter_login/login/login.dart';
import 'package:flutter_login/home/home.dart';

void main() {
  final authenticationBloc = AuthenticationBloc();

  runApp(App(
    authenticationBloc: authenticationBloc,
  ));
}

class App extends StatelessWidget {
  final AuthenticationBloc authenticationBloc;

  App({Key key, @required this.authenticationBloc}) : super(key: key) {
    authenticationBloc.onAppStart();
  }

  @override
  Widget build(BuildContext context) {
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
      builder: (BuildContext context, AuthenticationState state) {
        List<Widget> _widgets = [];

        if (state.isAuthenticated) {
          _widgets.add(HomePage());
        } else {
          _widgets.add(LoginPage());
        }

        if (state.isInitializing) {
          _widgets.add(SplashPage());
        }

        if (state.isLoading) {
          _widgets.add(_loadingIndicator());
        }

        return Stack(
          children: _widgets,
        );
      },
    );
  }

  Widget _loadingIndicator() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.3,
          child: ModalBarrier(dismissible: false, color: Colors.grey),
        ),
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}
