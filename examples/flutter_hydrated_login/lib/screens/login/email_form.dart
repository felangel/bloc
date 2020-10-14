import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hydrated_login/bloc/login/bloc.dart';
import 'package:flutter_hydrated_login/bloc/login/login_bloc.dart';

class EmailFormTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child:
            BlocBuilder<LoginBloc, LoginState>(buildWhen: (previous, current) {
          if (previous is MyFormChange && current is MyFormChange) {
            return previous.email != current.email;
          }
          return false;
        }, builder: (_, state) {
          var errorTextState = '';

          if (state is MyFormChange) {
            errorTextState = state.emailValidation();
          }
          return TextField(
            decoration:
                InputDecoration(hintText: 'Email', errorText: errorTextState),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              context.bloc<LoginBloc>().add(EmailChange(value));
            },
          );
        }));
  }
}
