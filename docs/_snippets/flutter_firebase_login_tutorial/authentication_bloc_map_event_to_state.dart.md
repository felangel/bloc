```dart
@override
Stream<AuthenticationState> mapEventToState(
  AuthenticationEvent event,
) async* {
  if (event is AuthenticationStarted) {
    yield* _mapAuthenticationStartedToState();
  } else if (event is AuthenticationLoggedIn) {
    yield* _mapAuthenticationLoggedInToState();
  } else if (event is AuthenticationLoggedOut) {
    yield* _mapAuthenticationLoggedOutToState();
  }
}

Stream<AuthenticationState> _mapAuthenticationStartedToState() async* {
  final isSignedIn = await _userRepository.isSignedIn();
  if (isSignedIn) {
    final name = await _userRepository.getUser();
    yield AuthenticationSuccess(name);
  } else {
    yield AuthenticationFailure();
  }
}

Stream<AuthenticationState> _mapAuthenticationLoggedInToState() async* {
  yield AuthenticationSuccess(await _userRepository.getUser());
}

Stream<AuthenticationState> _mapAuthenticationLoggedOutToState() async* {
  yield AuthenticationFailure();
  _userRepository.signOut();
}
```
