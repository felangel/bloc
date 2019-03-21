import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebaseauth/authentication/authentication.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: OutlineButton(
            padding: EdgeInsets.fromLTRB(8.0, 3.0, 8.0, 3.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Signin with GOOGLE',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
            color: Colors.black45,
            onPressed: () async {
              final AuthenticationBloc authenticationBloc =
                  BlocProvider.of<AuthenticationBloc>(context);
              authenticationBloc.dispatch(Login());
            }),
      ),
    );
  }
}
