<img src="https://raw.githubusercontent.com/felangel/bloc/master/doc/assets/flutter_bloc_logo_full.png" height="60" alt="Flutter Bloc Package" />

[![Build Status](https://travis-ci.org/felangel/bloc.svg?branch=master)](https://travis-ci.org/felangel/bloc)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Pub](https://img.shields.io/pub/v/flutter_bloc.svg)](https://pub.dartlang.org/packages/flutter_bloc)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Gitter](https://img.shields.io/badge/gitter-bloc-yellow.svg)](https://gitter.im/bloc_package/Lobby)

---

A Flutter package that helps implement the [Bloc pattern](https://www.youtube.com/watch?v=fahC3ky_zW0).

This package is built to work with [bloc](https://pub.dartlang.org/packages/bloc) 0.5.0+.

## Bloc Widgets

**BlocBuilder** is a Flutter widget which requires a `Bloc` and a `builder` function. `BlocBuilder` handles building the widget in response to new states. `BlocBuilder` is very similar to `StreamBuilder` but has a more simple API to reduce the amount of boilerplate code needed.

**BlocProvider** is a Flutter widget which provides a bloc to its children via `BlocProvider.of(context)`. It is used as a DI widget so that a single instance of a bloc can be provided to multiple widgets within a subtree.

## Usage

Lets take a look at how to use `BlocBuilder` to hook up a `LoginForm` widget to a `LoginBloc`.

```dart
  class LoginForm extends StatelessWidget {
    final LoginBloc loginBloc;
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    const LoginForm({Key key, @required this.loginBloc}): super(key: key);

    @override
    Widget build(BuildContext context) {
      return BlocBuilder<LoginEvent, LoginState>(
        bloc: loginBloc,
        builder: (
          BuildContext context,
          LoginState loginState,
        ) {
          if (loginState.token.isNotEmpty) {
            // user is authenticated do something...
          }

          return Form(
            child: Column(
              children: [
                Text(
                  loginState.error,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'username'),
                  controller: usernameController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'password'),
                  controller: passwordController,
                  obscureText: true,
                ),
                RaisedButton(
                  onPressed: loginState.isLoginButtonEnabled
                      ? _onLoginButtonPressed
                      : null,
                  child: Text('Login'),
                ),
                Container(
                  child:
                      loginState.isLoading ? CircularProgressIndicator() : null,
                ),
              ],
            ),
          );
        },
      );
    }

    _onLoginButtonPressed() {
      loginBloc.onLoginButtonPressed(
        username: usernameController.text,
        password: passwordController.text,
      );
    }
  }
```

At this point we have sucessfully separated our presentational layer from our business logic layer. Notice that the `LoginForm` widget knows nothing about what happens when a user taps the button. The form simply tells the `LoginBloc` that the user has pressed the button.

## Dart Versions

- Dart 2: >= 2.0.0

## Examples

- [Simple Counter Example](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example) - an example of how to create a `CounterBloc` to implement the classic Flutter Counter app.

### Contributors

- [Felix Angelov](https://github.com/felangel)
