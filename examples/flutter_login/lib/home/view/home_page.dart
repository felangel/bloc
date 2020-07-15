import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/authentication/authentication.dart';

class HomePage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(builder: (_) => HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: RaisedButton(
            child: const Text('Logout'),
            onPressed: () {
              context.bloc<AuthenticationBloc>().add(LoggedOut());
            },
          ),
        ),
      ),
    );
  }
}
