```dart
@override
Stream<AuthenticationState> mapEventToState(
  AuthenticationEvent event,
) async* {
  if (event is AuthenticationStarted) {
    final bool hasToken = await userRepository.hasToken();

    if (hasToken) {
      yield AuthenticationSuccess();
    } else {
      yield AuthenticationFailure();
    }
  }

  if (event is AuthenticationLoggedIn) {
    yield AuthenticationInProgress();
    await userRepository.persistToken(event.token);
    yield AuthenticationSuccess();
  }

  if (event is AuthenticationLoggedOut) {
    yield AuthenticationInProgress();
    await userRepository.deleteToken();
    yield AuthenticationFailure();
  }
}
```
