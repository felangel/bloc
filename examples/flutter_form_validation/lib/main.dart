import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_validation/bloc/bloc.dart';

main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Form Validation')),
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: BlocProvider(
            create: (context) => MyFormBloc(),
            child: MyForm(),
          ),
        ),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  MyFormBloc _myFormBloc;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _myFormBloc = BlocProvider.of<MyFormBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyFormBloc, MyFormState>(
      builder: (context, state) {
        if (state.formSubmittedSuccessfully) {
          return SuccessDialog(onDismissed: () {
            _emailController.clear();
            _passwordController.clear();
            _myFormBloc.add(FormReset());
          });
        }
        return Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  icon: Icon(Icons.email),
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                autovalidate: true,
                validator: (_) {
                  return state.isEmailValid ? null : 'Invalid Email';
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
                validator: (_) {
                  return state.isPasswordValid ? null : 'Invalid Password';
                },
              ),
              RaisedButton(
                onPressed: state.isFormValid ? _onSubmitPressed : null,
                child: Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _myFormBloc.add(EmailChanged(email: _emailController.text));
  }

  void _onPasswordChanged() {
    _myFormBloc.add(PasswordChanged(password: _passwordController.text));
  }

  void _onSubmitPressed() {
    _myFormBloc.add(FormSubmitted());
  }
}

class SuccessDialog extends StatelessWidget {
  final VoidCallback onDismissed;

  SuccessDialog({Key key, @required this.onDismissed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Icon(Icons.info),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Form Submitted Successfully!',
                    softWrap: true,
                  ),
                ),
              ),
            ],
          ),
          RaisedButton(
            child: Text('OK'),
            onPressed: onDismissed,
          ),
        ],
      ),
    );
  }
}
