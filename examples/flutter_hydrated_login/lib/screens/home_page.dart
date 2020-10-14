import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hydrated_login/bloc/auth/bloc.dart';
import 'package:flutter_hydrated_login/routes/app_routes.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                HydratedBloc.storage
                    .delete(context.bloc<AuthBloc>().storageToken);
                Navigator.pushReplacementNamed(context, AppRoutes.LOGIN);
              })
        ],
      ),
      body: Center(
        child: textInfo(context.bloc<AuthBloc>().state),
      ),
    );
  }

  Widget textInfo(AuthState state) {
    if (state is AuthUser) {
      return Column(
        children: [
          Text(state.user.uuid),
          Text(state.user.email),
        ],
      );
    }
    return const SizedBox();
  }
}
