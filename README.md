<img src="https://raw.githubusercontent.com/felangel/bloc/master/doc/assets/bloc_logo_full.png" height="60" alt="Bloc Architecture" />

[![Build Status](https://travis-ci.org/felangel/bloc.svg?branch=master)](https://travis-ci.org/felangel/bloc)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Pub](https://img.shields.io/pub/v/bloc.svg)](https://pub.dartlang.org/packages/bloc)

---

A dart package that helps implement the [Bloc pattern](https://www.youtube.com/watch?v=fahC3ky_zW0).

This package is built to work with [RxDart.dart](https://pub.dartlang.org/packages/rxdart) 0.18.1+.

## Bloc

<img src="https://raw.githubusercontent.com/felangel/bloc/master/doc/assets/bloc_architecture.png" alt="Bloc Architecture" />

The goal of this package is to make it easy to implement the `Bloc` Design Pattern (Business Logic Component).

This design pattern helps to separate _presentation_ from _business logic_. Following the Bloc pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on converting events into states.

### Glossary

**Events** are the input to a Bloc. They are commonly UI events such as button presses. `Events` are `dispatched` and then converted to `States`.

**States** are the output of a Bloc. Presentation components can listen to the stream of states and redraw portions of themselves based on the given state (see `BlocBuilder` for more details).

## Bloc Interface

**mapEventToState** is a method that **must be implemented** when a class extends `Bloc`. The function takes a single argument, event. `mapEventToState` is called whenever an event is `dispatched` by the presentation layer. `mapEventToState` must convert that event into a state and return the state in the form of a `Stream` so that it can be consumed by the presentation layer.

**dispatch** is a method that takes an `event` and triggers `mapEventToState`. `dispatch` maybe be called from the presentation layer or from within the Bloc (see examples) and notifies the Bloc of a new `event`.

**initialState** is the state before any events have been processed (before `mapEventToState` has ever been called). `initialState` is an optional getter. If unimplemented, initialState will be `null`.

**transform** is a method that can be overridden to transform the `Stream<Event>` before `mapEventToState` is called. This allows for operations like `distinct()` and `debounce()` to be used.

## Bloc Widgets

**BlocBuilder** is a Flutter widget which requires a `Bloc` and a `builder` function. `BlocBuilder` handles building the widget in response to new states. `BlocBuilder` is very similar to `StreamBuilder` but has a more simple API to reduce the amount of boilerplate code needed.

## Usage

For simplicity we can create a Bloc that always returns a stream of static strings in response to any event. That would look something like:

```dart
class SimpleBloc extends Bloc<dynamic, String> {
  @override
  Stream<String> mapEventToState(event) async* {
    yield 'data';
  }
}
```

That isn't a very realistic use-case so let's take something more practical like a login flow.

We're going to need to define what our different `LoginStates` are going to be.
For simplicity, let's say we only have 4 states:

- `initial`
- `loading`
- `error`
- `success`

```dart
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
    return LoginState({
      isLoading: false,
      isLoginButtonEnabled: true,
      error: '',
      token: '',
    });
  }

  factory LoginState.loading() {
    return LoginState({
      isLoading: true,
      isLoginButtonEnabled: false,
      error: '',
      token: '',
    });
  }

  factory LoginState.error(String error) {
    return LoginState({
      isLoading: false,
      isLoginButtonEnabled: true,
      error: error,
      token: '',
    });
  }

  factory LoginState.success(String token) {
    return LoginState({
      isLoading: false,
      isLoginButtonEnabled: true,
      error: '',
      token: token,
    });
  }
}
```

Next we need to define the different events that our Bloc will respond to. Again, for simplicity, let's say there is just a single event we will handle: `LoginButtonPressed`.

```dart
abstract class LoginEvent {}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  const LoginButtonPressed({@required this.username, @required this.password});
}
```

Now that we've identified our `states` and `events`, our `LoginBloc` should look something like:

```dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginState get initialState => LoginState.initial();

  void onLoginButtonPressed({String username, String password}) {
    dispatch(
      LoginButtonPressed(
        username: username,
        password: password,
      ),
    );
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginState.loading();

      try {
        final token = await _authenticate(event.username, event.password);
        yield LoginState.success(token);
      } catch (error) {
        yield LoginState.error(error.toString());
      }
    }
  }
}
```

Now that we have the `LoginBloc` lets take a look at how to use `BlocBuilder` to hook up our `LoginForm` widget to our `LoginBloc`.

```dart
  class LoginForm extends StatelessWidget {
    final LoginBloc loginBloc;
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    const LoginForm({Key key, @required this.loginBloc}): super(key: key);

    @override
    Widget build(BuildContext context) {
      return BlocBuilder<LoginState>(
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
                  controller: usernameController,
                ),
                TextFormField(
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
                  child: loginState.isLoading
                      ? CircularProgressIndicator()
                      : null,
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

At this point we have sucessfully separated our presentational layer from our business logic layer. Notice that the `LoginForm` widget knows nothing about what happens when a user taps the button. The form simply tells the `LoginBloc` that the user has pressed the button via `dispatch`. From that point, the `LoginBloc` tells the LoginForm to be in the loading state and proceeds to authenticate the user. If the user is successfully authenticated, the `LoginBloc` tells the `LoginForm` to be in the `LoginSuccess` state. If authentication failed, the `LoginBloc` tells the `LoginForm` to be in the `LoginError` state.

## Dart Versions

- Dart 2: >= 2.0.0

## Examples

- [Simple Theme Example](https://github.com/felangel/Bloc/tree/master/example) - an example of how to create a `ThemeBloc` to manage dynamically changing the theme of your flutter app.

### Contributors

- [Felix Angelov](https://github.com/felangel)
