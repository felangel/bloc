import 'package:flutter/material.dart' hide FormState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_authentication/form/form.dart';
import 'package:flutter_firebase_authentication/login/login.dart';

class LoginForm extends StatefulWidget {
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _loginBloc,
      listener: (BuildContext context, FormState state) {
        if (state is Editing && state.hasError) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Login Failure'),
            backgroundColor: Colors.red,
          ));
        }
      },
      child: BlocBuilder(
        bloc: _loginBloc,
        builder: (BuildContext context, FormState state) {
          return Form(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.email),
                    labelText: 'Email',
                  ),
                  autovalidate: true,
                  autocorrect: false,
                  validator: (_) {
                    return state is Editing && !state.isEmailValid
                        ? 'email cannot be empty'
                        : null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  autovalidate: true,
                  autocorrect: false,
                  validator: (_) {
                    return state is Editing && !state.isPasswordValid
                        ? 'password cannot be empty'
                        : null;
                  },
                ),
                state is Editing && state.isSubmitting
                    ? CircularProgressIndicator()
                    : RaisedButton(
                        onPressed: state is Editing && state.isFormValid
                            ? _onFormSubmitted
                            : null,
                        child: Text('Login'),
                      )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _loginBloc.dispatch(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _loginBloc.dispatch(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    _loginBloc.dispatch(
      LoginWithCredentialsPressed(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
