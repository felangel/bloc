import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hydrated_login/bloc/login/bloc.dart';


class PasswordFormTextField extends StatelessWidget {
  
  
  @override
  Widget build(BuildContext context) {
    
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child:
            BlocBuilder<LoginBloc, LoginState>(buildWhen: (previous, current) {
          if (previous is MyFormChange && current is MyFormChange) {
            return previous.password != current.password;
          }
          return false;
        }, builder: (_, state) {
          var errorTextState;
          if (state is MyFormChange) {
            errorTextState = state.passwordValidation();
          }
          return TextField(
            decoration: InputDecoration(
                hintText: 'Password', errorText: errorTextState),
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            onChanged: (value) {
              context.bloc<LoginBloc>().add(PasswordChange(value));
            },
          );
        }));
  }
}
