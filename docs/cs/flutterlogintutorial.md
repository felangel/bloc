# Tutoriál: Přihlašování ve Flutteru

?> **Poznámka:** Tento tutoriál ještě nemá překlad.

![intermediate](https://img.shields.io/badge/úroveň-středně%20pokročilý-orange.svg)

> In the following tutorial, we're going to build a Login Flow in Flutter using the Bloc library.

![demo](../assets/gifs/flutter_login.gif)

## Setup

We'll start off by creating a brand new Flutter project

```bash
flutter create flutter_login
```

We can then go ahead and replace the contents of `pubspec.yaml` with

```yaml
name: flutter_login
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: ">=2.0.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.1.0
  meta: ^1.1.6
  equatable: ^0.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

and then install all of our dependencies

```bash
flutter packages get
```

## User Repository

We're going to need to create a `UserRepository` which helps us manage a user's data.

```dart
class UserRepository {
  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    return 'token';
  }

  Future<void> deleteToken() async {
    /// delete from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<void> persistToken(String token) async {
    /// write to keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<bool> hasToken() async {
    /// read from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return false;
  }
}
```

?> **Note**: Our user repository is just mocking all of the different implementations for the sake of simplicity but in a real application you might inject a [HttpClient](https://pub.dev/packages/http) as well as something like [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) in order to request tokens and read/write them to keystore/keychain.

## Authentication States

Next, we’re going to need to determine how we’re going to manage the state of our application and create the necessary blocs (business logic components).

At a high level, we’re going to need to manage the user’s Authentication State. A user's authentication state can be one of the following:

- uninitialized - waiting to see if the user is authenticated or not on app start.
- loading - waiting to persist/delete a token
- authenticated - successfully authenticated
- unauthenticated - not authenticated

Each of these states will have an implication on what the user sees.

For example:

- if the authentication state was uninitialized, the user might be seeing a splash screen.
- if the authentication state was loading, the user might be seeing a progress indicator.
- if the authentication state was authenticated, the user might see a home screen.
- if the authentication state was unauthenticated, the user might see a login form.

> It's critical to identify what the different states are going to be before diving into the implementation.

Now that we have our authentication states identified, we can implement our `AuthenticationState` class.

```dart
import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthenticationUninitialized extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {}

class AuthenticationUnauthenticated extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}
```

?> **Note**: The [`equatable`](https://pub.dev/packages/equatable) package is used in order to be able to compare two instances of `AuthenticationState`. By default, `==` returns true only if the two objects are the same instance.

## Authentication Events

Now that we have our `AuthenticationState` defined we need to define the `AuthenticationEvents` which our `AuthenticationBloc` will be reacting to.

We will need:

- an `AppStarted` event to notify the bloc that it needs to check if the user is currently authenticated or not.
- a `LoggedIn` event to notify the bloc that the user has successfully logged in.
- a `LoggedOut` event to notify the bloc that the user has successfully logged out.

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final String token;

  const LoggedIn({@required this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'LoggedIn { token: $token }';
}

class LoggedOut extends AuthenticationEvent {}
```

?> **Note**: the `meta` package is used to annotate the `AuthenticationEvent` parameters as `@required`. This will cause the dart analyzer to warn developers if they don't provide the required parameters.

## Authentication Bloc

Now that we have our `AuthenticationState` and `AuthenticationEvents` defined, we can get to work on implementing the `AuthenticationBloc` which is going to manage checking and updating a user's `AuthenticationState` in response to `AuthenticationEvents`.

We'll start off by creating our `AuthenticationBloc` class.

```dart
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository}): assert(userRepository != null);
}
```

?> **Note**: Just from reading the class definition, we already know this bloc is going to be converting `AuthenticationEvents` into `AuthenticationStates`.

?> **Note**: Our `AuthenticationBloc` has a dependency on the `UserRepository`.

We can start by overriding `initialState` to the `AuthenticationUninitialized()` state.

```dart
@override
AuthenticationState get initialState => AuthenticationUninitialized();
```

Now all that's left is to implement `mapEventToState`.

```dart
@override
Stream<AuthenticationState> mapEventToState(
  AuthenticationEvent event,
) async* {
  if (event is AppStarted) {
    final bool hasToken = await userRepository.hasToken();

    if (hasToken) {
      yield AuthenticationAuthenticated();
    } else {
      yield AuthenticationUnauthenticated();
    }
  }

  if (event is LoggedIn) {
    yield AuthenticationLoading();
    await userRepository.persistToken(event.token);
    yield AuthenticationAuthenticated();
  }

  if (event is LoggedOut) {
    yield AuthenticationLoading();
    await userRepository.deleteToken();
    yield AuthenticationUnauthenticated();
  }
}
```

Great! Our final `AuthenticationBloc` should look like

```dart
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      final bool hasToken = await userRepository.hasToken();

      if (hasToken) {
        yield AuthenticationAuthenticated();
      } else {
        yield AuthenticationUnauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await userRepository.persistToken(event.token);
      yield AuthenticationAuthenticated();
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await userRepository.deleteToken();
      yield AuthenticationUnauthenticated();
    }
  }
}
```

Now that we have our `AuthenticationBloc` fully implemented, let’s get to work on the presentational layer.

## Splash Page

The first thing we’ll need is a `SplashPage` widget which will serve as our Splash Screen while our `AuthenticationBloc` determines whether or not a user is logged in.

```dart
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}
```

## Home Page

Next, we will need to create our `HomePage` so that we can navigate users there once they have successfully logged in.

```dart
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_login/authentication/authentication.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
        child: Center(
            child: RaisedButton(
          child: Text('logout'),
          onPressed: () {
            BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
          },
        )),
      ),
    );
  }
}
```

?> **Note**: This is the first class in which we are using `flutter_bloc`. We will get into `BlocProvider.of<AuthenticationBloc>(context)` shortly but for now just know that it allows our `HomePage` to access our `AuthenticationBloc`.

?> **Note**: We are adding a `LoggedOut` event to our `AuthenticationBloc` when a user pressed the logout button.

Next up, we need to create a `LoginPage` and `LoginForm`.

Because the `LoginForm` will have to handle user input (Login Button Pressed) and will need to have some business logic (getting a token for a given username/password), we will need to create a `LoginBloc`.

Just like we did for the `AuthenticationBloc`, we will need to define the `LoginState`, and `LoginEvents`. Let’s start with `LoginState`.

## Login States

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'LoginFailure { error: $error }';
}
```

`LoginInitial` is the initial state of the LoginForm.

`LoginLoading` is the state of the LoginForm when we are validating credentials

`LoginFailure` is the state of the LoginForm when a login attempt has failed.

Now that we have the `LoginState` defined let’s take a look at the `LoginEvent` class.

## Login Events

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  const LoginButtonPressed({
    @required this.username,
    @required this.password,
  });

  @override
  List<Object> get props => [username, password];

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password }';
}
```

`LoginButtonPressed` will be added when a user pressed the login button. It will notify the `LoginBloc` that it needs to request a token for the given credentials.

We can now implement our `LoginBloc`.

## Login Bloc

```dart
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/login/login.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final token = await userRepository.authenticate(
          username: event.username,
          password: event.password,
        );

        authenticationBloc.add(LoggedIn(token: token));
        yield LoginInitial();
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    }
  }
}
```

?> **Note**: `LoginBloc` has a dependency on `UserRepository` in order to authenticate a user given a username and password.

?> **Note**: `LoginBloc` has a dependency on `AuthenticationBloc` in order to update the AuthenticationState when a user has entered valid credentials.

Now that we have our `LoginBloc` we can start working on `LoginPage` and `LoginForm`.

## Login Page

The `LoginPage` widget will serve as our container widget and will provide the necessary dependencies to the `LoginForm` widget (`LoginBloc` and `AuthenticationBloc`).

```dart
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/login/login.dart';

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            userRepository: userRepository,
          );
        },
        child: LoginForm(),
      ),
    );
  }
}
```

?> **Note**: `LoginPage` is a `StatelessWidget`. The `LoginPage` widget uses the `BlocProvider` widget to create, close, and provide the `LoginBloc` to the sub-tree.

?> **Note**: We are using the injected `UserRepository` in order to create our `LoginBloc`.

?> **Note**: We are using `BlocProvider.of<AuthenticationBloc>(context)` again in order to access the `AuthenticationBloc` from the `LoginPage`.

Next up, let’s go ahead and create our `LoginForm`.

## Login Form

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/login/login.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _onLoginButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(
        LoginButtonPressed(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'username'),
                  controller: _usernameController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'password'),
                  controller: _passwordController,
                  obscureText: true,
                ),
                RaisedButton(
                  onPressed:
                      state is! LoginLoading ? _onLoginButtonPressed : null,
                  child: Text('Login'),
                ),
                Container(
                  child: state is LoginLoading
                      ? CircularProgressIndicator()
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

?> **Note**: Our `LoginForm` uses the `BlocBuilder` widget so that it can rebuild whenever there is a new `LoginState`. `BlocBuilder` is a Flutter widget which requires a Bloc and a builder function. `BlocBuilder` handles building the widget in response to new states. `BlocBuilder` is very similar to `StreamBuilder` but has a more simple API to reduce the amount of boilerplate code needed and various performance optimizations.

There’s not much else going on in the `LoginForm` widget so let's move on to creating our loading indicator.

## Loading Indicator

```dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(),
      );
}
```

Now it’s finally time to put it all together and create our main App widget in `main.dart`.

## Putting it all together

```dart
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/splash/splash.dart';
import 'package:flutter_login/login/login.dart';
import 'package:flutter_login/home/home.dart';
import 'package:flutter_login/common/common.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final userRepository = UserRepository();
  runApp(
    BlocProvider<AuthenticationBloc>(
      create: (context) {
        return AuthenticationBloc(userRepository: userRepository)
          ..add(AppStarted());
      },
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationUninitialized) {
            return SplashPage();
          }
          if (state is AuthenticationAuthenticated) {
            return HomePage();
          }
          if (state is AuthenticationUnauthenticated) {
            return LoginPage(userRepository: userRepository);
          }
          if (state is AuthenticationLoading) {
            return LoadingIndicator();
          }
        },
      ),
    );
  }
}
```

?> **Note**: Again, we are using `BlocBuilder` in order to react to changes in `AuthenticationState` so that we can show the user either the `SplashPage`, `LoginPage`, `HomePage`, or `LoadingIndicator` based on the current `AuthenticationState`.

?> **Note**: Our app is wrapped in a `BlocProvider` which makes our instance of `AuthenticationBloc` available to the entire widget subtree. `BlocProvider` is a Flutter widget which provides a bloc to its children via `BlocProvider.of(context)`. It is used as a dependency injection (DI) widget so that a single instance of a bloc can be provided to multiple widgets within a subtree.

Now `BlocProvider.of<AuthenticationBloc>(context)` in our `HomePage` and `LoginPage` widget should make sense.

Since we wrapped our `App` within a `BlocProvider<AuthenticationBloc>` we can access the instance of our `AuthenticationBloc` by using the `BlocProvider.of<AuthenticationBloc>(BuildContext context)` static method from anywhere in the subtree.

At this point we have a pretty solid login implementation and we have decoupled our presentation layer from the business logic layer by using Bloc.

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
