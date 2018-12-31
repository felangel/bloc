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
