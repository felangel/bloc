# Login Tutorial

> In the following tutorial, we're going to build a Login Flow in Flutter using the Bloc library.

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
  sdk: ">=2.0.0-dev.68.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  bloc: ^0.7.7
  flutter_bloc: ^0.4.11
  meta: ^1.1.6

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

?> **Note**: Our user repository is just mocking all of the different implementations for the sake of simplicity but in a real application you might inject a [HttpClient](https://pub.dartlang.org/packages/http) as well as something like [Flutter Secure Storage](https://pub.dartlang.org/packages/flutter_secure_storage) in order to request tokens and read/write them to keystore/keychain.

## Authentication States

Next, we’re going to need to determine how we’re going to manage the state of our application and create the necessary blocs (business logic components).

At a high level, we’re going to need to manage the user’s Authentication State. A user's authentication state can be one of the following:

- uninitialized - waiting to see if the user is authenticated or not on app start.
- initialized + loading - waiting to validate credentials and/or persist a token
- initialized + authenticated - successfully authenticated
- initialized + unauthenticated - not authenticated

Each of these states will have an implication on what the user sees.

For example:

- if the authentication state was uninitialized, the user might be seeing a splash screen.
- if the authentication state was initialized but loading, the user might be seeing a progress indicator.
- if the authentication state was initialized and authenticated, the user might see a home screen.
- if the authentication state was initialized and unauthenticated, the user might see a login form.

> It's critical to identify what the different states are going to be before diving into the implementation.

Now that we have our authentication states identified, we can implement our `AuthenticationState` class.

```dart
import 'package:meta/meta.dart';

abstract class AuthenticationState {}

class AuthenticationUninitialized extends AuthenticationState {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is AuthenticationUninitialized && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthenticationUninitialized';
}

class AuthenticationInitialized extends AuthenticationState {
  final bool isLoading;
  final bool isAuthenticated;

  AuthenticationInitialized({
    @required this.isLoading,
    @required this.isAuthenticated,
  });

  factory AuthenticationInitialized.authenticated() {
    return AuthenticationInitialized(
      isAuthenticated: true,
      isLoading: false,
    );
  }

  factory AuthenticationInitialized.unauthenticated() {
    return AuthenticationInitialized(
      isAuthenticated: false,
      isLoading: false,
    );
  }

  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is AuthenticationInitialized &&
          runtimeType == other.runtimeType &&
          isAuthenticated == other.isAuthenticated &&
          isLoading == other.isLoading;

  @override
  int get hashCode => isAuthenticated.hashCode ^ isLoading.hashCode;

  @override
  String toString() =>
      'AuthenticationInitialized { isLoading: $isLoading, isAuthenticated: $isAuthenticated }';
}
```

`isAuthenticated` corresponds to whether or not the current user is authenticated.

`isLoading` corresponds to whether or not the application displays a loading indicator.

?> **Note**: the `factory` pattern is used for convenience and readability. Instead of manually creating an instance of `AuthenticationState` we can simply write `AuthenticationState.authenticated()`.

?> **Note**: `==` and `hashCode` are overridden in order to be able to compare two instances of `AuthenticationState`. By default, `==` returns true only if the two objects are the same instance.

?> **Note**: `toString` is overridden to make it easier to read an `AuthenticationState` when printing it to the console or in `Transitions`.

?> **Note**: the `meta` package is used to annotate the `AuthenticationState` parameters as `@required`. This will cause the dart analyzer to warn developers if they don't provide the required parameters.

## Authentication Events

Now that we have our `AuthenticationState` defined we need to define the `AuthenticationEvents` which our `AuthenticationBloc` will be reacting to.

We will need:

- an `AppStart` event to notify the bloc that it needs to check if the user is currently authenticated or not.
- a `Login` event to notify the bloc that the user has successfully logged in.
- a `Logout` event to notify the bloc that the user has successfully logged out.

```dart
import 'package:meta/meta.dart';

abstract class AuthenticationEvent {}

class AppStart extends AuthenticationEvent {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppStart && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AppStart';
}

class Login extends AuthenticationEvent {
  final String token;

  Login({@required this.token});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Login &&
          runtimeType == other.runtimeType &&
          token == other.token;

  @override
  int get hashCode => token.hashCode;

  @override
  String toString() => 'Login { token: $token }';
}

class Logout extends AuthenticationEvent {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Logout && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Logout';
}
```

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
  AuthenticationState currentState,
  AuthenticationEvent event,
) async* {
  if (event is AppStart) {
    final bool hasToken = await userRepository.hasToken();
    if (hasToken) {
      yield AuthenticationInitialized.authenticated();
    } else {
      yield AuthenticationInitialized.unauthenticated();
    }
  }

  if (event is Login) {
    yield AuthenticationInitialized(isAuthenticated: false, isLoading: true);
    await userRepository.persistToken(event.token);
    yield AuthenticationInitialized.authenticated();
  }

  if (event is Logout) {
    yield AuthenticationInitialized(isAuthenticated: true, isLoading: true);
    await userRepository.deleteToken();
    yield AuthenticationInitialized.unauthenticated();
  }
}
```

Great! Our final `AuthenticationBloc` should look like

```dart
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:flutter_login/user_repository/user_repository.dart';
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
    AuthenticationState currentState,
    AuthenticationEvent event,
  ) async* {
    if (event is AppStart) {
      final bool hasToken = await userRepository.hasToken();

      if (hasToken) {
        yield AuthenticationInitialized.authenticated();
      } else {
        yield AuthenticationInitialized.unauthenticated();
      }
    }

    if (event is Login) {
      yield AuthenticationInitialized(isAuthenticated: false, isLoading: true);
      await userRepository.persistToken(event.token);
      yield AuthenticationInitialized.authenticated();
    }

    if (event is Logout) {
      yield AuthenticationInitialized(isAuthenticated: true, isLoading: true);
      await userRepository.deleteToken();
      yield AuthenticationInitialized.unauthenticated();
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
    final AuthenticationBloc authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
        child: Center(
            child: RaisedButton(
          child: Text('logout'),
          onPressed: () {
            authenticationBloc.dispatch(Logout());
          },
        )),
      ),
    );
  }
}
```

?> **Note**: This is the first class in which we are using `flutter_bloc`. We will get into `BlocProvider.of<AuthenticationBloc>(context)` shortly but for now just know that it allows our `HomePage` to access our `AuthenticationBloc`.

?> **Note**: We are dispatching a `Logout` event to our `AuthenticationBloc` when a user pressed the logout button.

Next up, we need to create a `LoginPage` and `LoginForm`.

Because the `LoginForm` will have to handle user input (Login Button Pressed) and will need to have some business logic (getting a token for a given username/password), we will need to create a `LoginBloc`.

Just like we did for the `AuthenticationBloc`, we will need to define the `LoginState`, and `LoginEvents`. Let’s start with `LoginState`.

## Login States

```dart
import 'package:meta/meta.dart';

class LoginState {
  final bool isLoading;
  final bool isLoginButtonEnabled;
  final String error;
  final String token;

  const LoginState({
    @required this.isLoading,
    @required this.isLoginButtonEnabled,
    @required this.error,
    @required this.token,
  });

  factory LoginState.initial() {
    return LoginState(
      isLoading: false,
      isLoginButtonEnabled: true,
      error: '',
      token: '',
    );
  }

  factory LoginState.loading() {
    return LoginState(
      isLoading: true,
      isLoginButtonEnabled: false,
      error: '',
      token: '',
    );
  }

  factory LoginState.failure(String error) {
    return LoginState(
      isLoading: false,
      isLoginButtonEnabled: true,
      error: error,
      token: '',
    );
  }

  factory LoginState.success(String token) {
    return LoginState(
      isLoading: false,
      isLoginButtonEnabled: true,
      error: '',
      token: token,
    );
  }

  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is LoginState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          isLoginButtonEnabled == other.isLoginButtonEnabled &&
          error == other.error &&
          token == other.token;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      isLoginButtonEnabled.hashCode ^
      error.hashCode ^
      token.hashCode;

  @override
  String toString() =>
      'LoginState { isLoading: $isLoading, isLoginButtonEnabled: $isLoginButtonEnabled, error: $error, token: $token }';
}
```

`isLoading` corresponds to whether or not we show a loading indicator while trying to process the entered username/password.

`isLoginButtonEnabled` corresponds to whether or not the user can tap the login button.

`error` corresponds to any errors encountered during the login process.

`token` corresponds to the user’s token.

Now that we have the `LoginState` defined let’s take a look at the `LoginEvent` class.

## Login Events

```dart
import 'package:meta/meta.dart';

import 'package:flutter/widgets.dart';

abstract class LoginEvent {}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  LoginButtonPressed({
    @required this.username,
    @required this.password,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginButtonPressed &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          password == other.password;

  @override
  int get hashCode => username.hashCode ^ password.hashCode;

  @override
  String toString() => 'LoginButtonPressed { username: $username, password: $password }';
}

class LoggedIn extends LoginEvent {
  @override
  String toString() => 'LoggedIn';
}
```

`LoginButtonPressed` will be dispatched when a user pressed the login button. It will notify the `LoginBloc` that it needs to request a token for the given credentials.

`LoggedIn` will be dispatched when a user has successfully retrieved a token. It will notify the `LoginBloc` that it needs to reset the `LoginState`.

We can now implement our `LoginBloc`.

## Login Bloc

```dart
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:flutter_login/user_repository/user_repository.dart';
import 'package:flutter_login/login/login.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;

  LoginBloc({@required this.userRepository}): assert(userRepository != null);

  @override
  LoginState get initialState => LoginState.initial();

  @override
  Stream<LoginState> mapEventToState(
    LoginState currentState,
    LoginEvent event,
  ) async* {
    if (event is LoginButtonPressed) {
      yield LoginState.loading();

      try {
        final token = await userRepository.authenticate(
          username: event.username,
          password: event.password,
        );

        yield LoginState.success(token);
      } catch (error) {
        yield LoginState.failure(error.toString());
      }
    }

    if (event is LoggedIn) {
      yield LoginState.initial();
    }
  }
}
```

?> **Note**: `LoginBloc` has a dependency on `UserRepository` in order to authenticate a user given a username and password.

Now that we have our `LoginBloc` we can start working on `LoginPage` and `LoginForm`.

## Login Page

The `LoginPage` widget will serve as our container widget and will provide the necessary dependencies to the `LoginForm` widget (`LoginBloc` and `AuthenticationBloc`).

```dart
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_login/user_repository/user_repository.dart';
import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/login/login.dart';

class LoginPage extends StatefulWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository}): assert(userRepository != null), super(key: key);

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  LoginBloc _loginBloc;

  @override
  void initState() {
    _loginBloc = LoginBloc(userRepository: widget.userRepository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: LoginForm(
        authBloc: BlocProvider.of<AuthenticationBloc>(context),
        loginBloc: _loginBloc,
      ),
    );
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }
}
```

?> **Note**: `LoginPage` is a `StatefulWidget`. The `LoginPage` widget creates the `LoginBloc` as part of its state and handles disposing it.

?> **Note**: We are using the injected `UserRepository` in order to create our `LoginBloc`.

?> **Note**: We are using `BlocProvider.of<AuthenticationBloc>(context)` again in order to access the `AuthenticationBloc` from the `LoginPage`.

Next up, let’s go ahead and create our `LoginForm`.

## Login Form

```dart
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/login/login.dart';

class LoginForm extends StatefulWidget {
  final LoginBloc loginBloc;
  final AuthenticationBloc authBloc;

  LoginForm({
    Key key,
    @required this.loginBloc,
    @required this.authBloc,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginEvent, LoginState>(
      bloc: widget.loginBloc,
      builder: (
        BuildContext context,
        LoginState loginState,
      ) {
        if (_loginSucceeded(loginState)) {
          widget.authBloc.dispatch(Login(token: loginState.token));
          widget.loginBloc.dispatch(LoggedIn());
        }

        if (_loginFailed(loginState)) {
          _onWidgetDidBuild(() {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${loginState.error}'),
                backgroundColor: Colors.red,
              ),
            );
          });
        }

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
                    loginState.isLoginButtonEnabled ? _onLoginButtonPressed : null,
                child: Text('Login'),
              ),
              Container(
                child: loginState.isLoading ? CircularProgressIndicator() : null,
              ),
            ],
          ),
        );
      },
    );
  }

  bool _loginSucceeded(LoginState state) => state.token.isNotEmpty;

  bool _loginFailed(LoginState state) => state.error.isNotEmpty;

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  _onLoginButtonPressed() {
    widget.loginBloc.dispatch(LoginButtonPressed(
      username: _usernameController.text,
      password: _passwordController.text,
    ));
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
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.3,
          child: ModalBarrier(dismissible: false, color: Colors.grey),
        ),
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}
```

Now it’s finally time to put it all together and create our main App widget in `main.dart`.

## Putting it all together

```dart
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_login/user_repository/user_repository.dart';
import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/splash/splash.dart';
import 'package:flutter_login/login/login.dart';
import 'package:flutter_login/home/home.dart';
import 'package:flutter_login/common/common.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  final UserRepository _userRepository = UserRepository();
  AuthenticationBloc _authenticationBloc;

  @override
  void initState() {
    _authenticationBloc = AuthenticationBloc(userRepository: _userRepository);
    _authenticationBloc.dispatch(AppStart());
    super.initState();
  }

  @override
  void dispose() {
    _authenticationBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      bloc: _authenticationBloc,
      child: MaterialApp(
        home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
          bloc: _authenticationBloc,
          builder: (BuildContext context, AuthenticationState state) {
            List<Widget> widgets = [];

            if (state is AuthenticationUninitialized) {
              widgets.add(SplashPage());
            }
            if (state is AuthenticationInitialized) {

              if (state.isAuthenticated) {
                widgets.add(HomePage());
              } else {
                widgets.add(LoginPage(
                  userRepository: _userRepository,
                ));
              }

              if (state.isLoading) {
                widgets.add(LoadingIndicator());
              }
            }

            return Stack(
              children: widgets,
            );
          },
        ),
      ),
    );
  }
}
```

?> **Note**: Again, we are using `BlocBuilder` in order to react to changes in `AuthenticationState` so that we can show the user either the `SplashPage`, `LoginPage`, or `HomePage` based on the current `AuthenticationState`.

?> **Note**: Our app has an injected `AuthenticationBloc` which it makes available to the entire widget subtree by using the `BlocProvider` widget. `BlocProvider` is a Flutter widget which provides a bloc to its children via `BlocProvider.of(context)`. It is used as a dependency injection (DI) widget so that a single instance of a bloc can be provided to multiple widgets within a subtree.

Now `BlocProvider.of<AuthenticationBloc>(context)` in our `HomePage` and `LoginPage` widget should make sense.

Since we wrapped our `MaterialApp` within a `BlocProvider<AuthenticationBloc>` we can access the instance of our `AuthenticationBloc` by using the `BlocProvider.of<AuthenticationBloc>(BuildContext context)` static method from anywhere in the subtree.

At this point we have a pretty solid login implementation and we have decoupled our presentation layer from the business logic layer by using Bloc.

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
