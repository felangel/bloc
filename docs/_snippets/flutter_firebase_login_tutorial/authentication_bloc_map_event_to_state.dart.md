```dart
@override
Stream<AuthenticationState> mapEventToState(
  AuthenticationEvent event,
) async* {
  if (event is AppStarted) {
    yield* _mapAppStartedToState();
  } else if (event is LoggedIn) {
    yield* _mapLoggedInToState();
  } else if (event is LoggedOut) {
    yield* _mapLoggedOutToState();
  }
}

Stream<AuthenticationState> _mapAppStartedToState() async* {
  final isSignedIn = await _userRepository.isSignedIn();
  if (isSignedIn) {
    final name = await _userRepository.getUser();
    yield Authenticated(name);
  } else {
    yield Unauthenticated();
  }
}

Stream<AuthenticationState> _mapLoggedInToState() async* {
  yield Authenticated(await _userRepository.getUser());
}

Stream<AuthenticationState> _mapLoggedOutToState() async* {
  yield Unauthenticated();
  _userRepository.signOut();
}
```
