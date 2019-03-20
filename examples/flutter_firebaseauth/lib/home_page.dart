import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebaseauth/authentication/authentication.dart';

class HomePage extends StatelessWidget {
  final AuthenticationAuthenticated userState;

  const HomePage({Key key, this.userState}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final AuthenticationBloc authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome,\n' + this.userState.user.displayName,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            RaisedButton(
              child: Text('logout'),
              onPressed: () {
                authenticationBloc.dispatch(LogOut());
              },
            ),
          ],
        )),
      ),
    );
  }
}
