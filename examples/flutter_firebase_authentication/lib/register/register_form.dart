import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_authentication/register/register.dart';
import 'package:flutter_firebase_authentication/form/form.dart';

class RegisterForm extends StatefulWidget {
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  RegisterBloc _registerBloc;

  @override
  void initState() {
    super.initState();
    _registerBloc = BlocProvider.of<RegisterBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _registerBloc,
      listener: (BuildContext context, MyFormState state) {
        if (state.isSuccess) {
          Navigator.of(context).pop();
        }
        if (state.isFailure) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Registration Failure'),
            backgroundColor: Colors.red,
          ));
        }
      },
      child: BlocBuilder(
        bloc: _registerBloc,
        builder: (BuildContext context, MyFormState state) {
          return Form(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.email),
                    labelText: 'Email',
                  ),
                  autocorrect: false,
                  autovalidate: true,
                  validator: (_) {
                    return !state.isEmailValid ? 'Invalid Email' : null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  autocorrect: false,
                  autovalidate: true,
                  validator: (_) {
                    return !state.isPasswordValid ? 'Invalid Password' : null;
                  },
                ),
                state.isSubmitting
                    ? CircularProgressIndicator()
                    : RaisedButton(
                        onPressed: state.isEmailValid &&
                                state.isPasswordValid &&
                                isPopulated
                            ? _onFormSubmitted
                            : null,
                        child: Text('Sign Up'),
                      ),
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
    _registerBloc.dispatch(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _registerBloc.dispatch(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    _registerBloc.dispatch(
      Submitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
