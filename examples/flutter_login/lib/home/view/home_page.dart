import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/login/view/login_page.dart';
import 'package:flutter_login/profile/bloc/profile_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class HomePage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            itemText(context),
            RaisedButton(
              child: const Text('Logout'),
              onPressed: () {
                context.bloc<ProfileBloc>().clear();
                context
                    .bloc<AuthenticationBloc>()
                    .add(AuthenticationLogoutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget itemText(BuildContext context) {
    final profileState = context.bloc<ProfileBloc>().state;
    if (profileState is ProfileUser) {
      return Text('UserID: ${profileState.user.id}');
    }
    return const Text('UserID: 0');
  }
}
