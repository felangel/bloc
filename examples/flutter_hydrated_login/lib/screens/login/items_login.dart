import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hydrated_login/bloc/auth/bloc.dart';
import 'package:flutter_hydrated_login/bloc/login/bloc.dart';
import 'package:flutter_hydrated_login/routes/app_routes.dart';
import 'package:flutter_hydrated_login/screens/login/button_login.dart';
import 'package:flutter_hydrated_login/screens/login/email_form.dart';
import 'package:flutter_hydrated_login/screens/login/password_form.dart';

class ItemsLogin extends StatelessWidget {
  BuildContext _buildContext;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    _buildContext = context;

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is MyFormChange) {
          onListenLoginPage(state);
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text('error')));
        }
      },
      child: SizedBox(
        width: media.size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EmailFormTextField(),
            PasswordFormTextField(),
            ButtonLogin()
          ],
        ),
      ),
    );
  }

  void onListenLoginPage(MyFormChange state) {
    if (state.userState?.user != null) {
      _buildContext.bloc<AuthBloc>().add(AuthLogin(state.userState.user.email,
          state.userState.user.password, state.userState.user.uuid));
      Navigator.pushReplacementNamed(_buildContext, AppRoutes.HOME);
    }

    final status = state.email.isNotEmpty &&
        state.password.isNotEmpty &&
        state.emailValidation() == null &&
        state.passwordValidation() == null;

    _buildContext.bloc<LoginBloc>().add(ButtonActive(status));
  }
}
