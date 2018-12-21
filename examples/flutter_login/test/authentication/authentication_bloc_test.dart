import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_login/authentication/authentication.dart';

void main() {
  AuthenticationBloc authenticationBloc;

  setUp(() {
    authenticationBloc = AuthenticationBloc();
  });

  test('initial state is correct', () {
    expect(authenticationBloc.initialState, AuthenticationState.initializing());
  });

  test('dispose does not emit new states', () {
    expectLater(
      authenticationBloc.state,
      emitsInOrder([]),
    );
    authenticationBloc.dispose();
  });

  group('AppStarted', () {
    test('emits [initializing, unauthenticated] for invalid token', () {
      final expectedResponse = [
        AuthenticationState.initializing(),
        AuthenticationState.unauthenticated(),
      ];

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(AppStart());
    });
  });

  group('LoggedIn', () {
    test('emits [initializing, loading, authenticated] when token is persisted',
        () {
      final expectedResponse = [
        AuthenticationState.initializing(),
        AuthenticationState.initializing().copyWith(isLoading: true),
        AuthenticationState.authenticated(),
      ];

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(Login(
        token: 'instance.token',
      ));
    });
  });

  group('LoggedOut', () {
    test('emits [initializing, loading, unauthenticated] when token is deleted',
        () {
      final expectedResponse = [
        AuthenticationState.initializing(),
        AuthenticationState.initializing().copyWith(isLoading: true),
        AuthenticationState.unauthenticated(),
      ];

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(Logout());
    });
  });
}
