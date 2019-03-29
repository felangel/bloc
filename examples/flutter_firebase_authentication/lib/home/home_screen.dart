import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_firebase_authentication/authentication/authentication.dart';

class HomeScreen extends StatelessWidget {
  final String name;

  HomeScreen({Key key, @required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Firebase Authentication'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(child: Text('Welcome $name!')),
          Center(
            child: RaisedButton(
              onPressed: () {
                BlocProvider.of<AuthenticationBloc>(context).dispatch(Logout());
              },
              child: Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }
}
