import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_authentication/authentication/authentication.dart';

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        BlocProvider.of<AuthenticationBloc>(context).dispatch(
          LoggedOut(),
        );
      },
      child: Text('Sign Out'),
    );
  }
}
