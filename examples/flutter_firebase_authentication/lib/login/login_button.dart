import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_authentication/login/login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LoginBloc _loginBloc = BlocProvider.of<LoginBloc>(context);
    return BlocBuilder(
      bloc: _loginBloc,
      builder: (BuildContext context, LoginState state) {
        return Center(
          child: ButtonTheme(
            minWidth: 150.0,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              icon: Icon(FontAwesomeIcons.google, color: Colors.white),
              onPressed: () {
                _loginBloc.dispatch(LoginPressed());
              },
              label: Text('Sign In', style: TextStyle(color: Colors.white)),
              color: Theme.of(context).accentColor,
            ),
          ),
        );
      },
    );
  }
}
