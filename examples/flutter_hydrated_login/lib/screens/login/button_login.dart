import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hydrated_login/bloc/login/bloc.dart';

class ButtonLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (previous, current) {
            if (previous is MyFormChange && current is MyFormChange) {
              return previous.isActive != current.isActive;
            }
            return false;
          },
          builder: (context, state) {
            bool isActive = false;

            if (state is MyFormChange) {
              isActive = state.isActive;
            }

            return RaisedButton(
              onPressed: isActive ? () => _onTapLogin(context) : null,
              child: Text('Login'),
            );
          },
        ),
      ),
    );
  }

  void _onTapLogin(BuildContext context) {
    final state = context.bloc<LoginBloc>().state as MyFormChange;
    context.bloc<LoginBloc>().add(SubmitLogin(state.email, state.password));
  }
}
