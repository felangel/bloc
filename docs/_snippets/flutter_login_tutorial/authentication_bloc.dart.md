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
  AuthenticationState get initialState => AuthenticationInitial();

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
}
```
