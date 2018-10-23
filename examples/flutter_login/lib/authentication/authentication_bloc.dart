import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:flutter_login/authentication/authentication.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  void onAppStart() {
    dispatch(AppStart());
  }

  void onAuthenticationSuccess({@required String token}) {
    dispatch(AuthenticationSuccess(token: token));
  }

  void onLogoutPressed() {
    dispatch(LogoutPressed());
  }

  @override
  AuthenticationState get initialState => AuthenticationState.initializing();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationState state, AuthenticationEvent event) async* {
    if (event is AppStart) {
      try {
        final hasToken = await _hasToken();
        if (hasToken == false) {
          throw Exception('unauthenticated');
        }
        yield state.copyWith(isAuthenticated: true, isInitializing: false);
      } catch (error) {
        yield state.copyWith(isAuthenticated: false, isInitializing: false);
      }
    }

    if (event is AuthenticationSuccess) {
      yield state.copyWith(isLoading: true);

      try {
        await _persistToken(event.token);
        yield state.copyWith(isAuthenticated: true);
      } catch (error) {
        yield state.copyWith(isAuthenticated: false);
      }
    }

    if (event is LogoutPressed) {
      yield state.copyWith(isLoading: true);

      try {
        await _deleteToken();
        yield state.copyWith(isAuthenticated: false);
      } catch (error) {
        // handle error
      }
    }
  }

  Future<void> _deleteToken() async {
    // delete from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<void> _persistToken(String token) async {
    // write to keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<bool> _hasToken() async {
    // read from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return false;
  }
}
