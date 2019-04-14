import 'package:flutter/material.dart' hide FormState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_authentication/register/register.dart';
import 'package:flutter_firebase_authentication/form/form.dart';

class RegisterForm extends StatefulWidget {
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
      listener: (BuildContext context, FormState state) {
        if (state is Editing && state.submittedSuccessfully) {
          Navigator.of(context).pop();
        }
        if (state is Editing && state.hasError) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Registration Failure'),
            backgroundColor: Colors.red,
          ));
        }
      },
      child: BlocBuilder(
        bloc: _registerBloc,
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
                        ? 'Invalid Email'
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
                        ? 'Invalid Password'
                        : null;
                  },
                ),
                state is Editing && state.isSubmitting
                    ? CircularProgressIndicator()
                    : RaisedButton(
                        onPressed: state is Editing && state.isFormValid
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
