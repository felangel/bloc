import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hydrated_login/bloc/login/bloc.dart';
import 'package:flutter_hydrated_login/repositorys/auth_repository.dart';
import 'package:flutter_hydrated_login/screens/login/items_login.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) => LoginBloc(context.repository<AuthRepository>()),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
          ),
          body: ItemsLogin()),
    );
  }
}
