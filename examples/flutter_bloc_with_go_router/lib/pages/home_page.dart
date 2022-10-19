import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/authentication_bloc.dart';
import '../bloc/authentication_event.dart';
import '../type/authentication_status_type.dart';

/// after login, home page will show user's info
class HomePage extends StatefulWidget {
  /// Creates an [HomePage].
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You are logged in successfully!!!'),
            ElevatedButton(
              onPressed: () {
                const AuthenticationStatusChanged event =
                    AuthenticationStatusChanged(
                        AuthenticationStatusType.unauthenticated);
                context.read<AuthenticationBloc>().add(event);
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
