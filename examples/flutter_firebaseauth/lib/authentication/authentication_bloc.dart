import 'dart:async';
import 'package:bloc/bloc.dart';

import 'package:flutter_firebaseauth/authentication/authentication.dart';
import 'package:flutter_firebaseauth/authentication/authentication_service.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {

  final FirebaseAuthService firebaseAuthService;

  AuthenticationBloc({this.firebaseAuthService});
  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationState currentState,
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      final user = await this.firebaseAuthService.getInitialSignInState();
      if (user == null)
        yield AuthenticationUnauthenticated();
      else
        yield AuthenticationAuthenticated(user: user);
    }

    if (event is LogIn) {
      try {
        final user = await this.firebaseAuthService.sigInWithGoogle();

        if (user == null) {
          yield AuthenticationLoading();
          yield AuthenticationUnauthenticated();
        } else {
          yield AuthenticationLoading();
          yield AuthenticationAuthenticated(user: user);
        }
      } catch (e) {
        print(e.toString());
        return;
      }
    }

    if (event is LogOut) {
      yield AuthenticationLoading();
      //logout user
      await this.firebaseAuthService.signOutFromGoogle();
      yield AuthenticationUnauthenticated();
    }
  }
}
