import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_firebaseauth/authentication/authentication.dart';
import 'package:flutter_firebaseauth/authentication/authentication_service.dart';

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

class MockFirebaseUser extends Mock implements FirebaseUser {}

void main() {
  AuthenticationBloc authenticationBloc;
  MockFirebaseAuthService mockFirebaseAuthService;
  MockFirebaseUser mockFirebaseUser;

  setUp(() {
    mockFirebaseAuthService = MockFirebaseAuthService();
    authenticationBloc =
        AuthenticationBloc(firebaseAuthService: mockFirebaseAuthService);
    mockFirebaseUser = MockFirebaseUser();
  });

  test('initial state is correct', () {
    expect(authenticationBloc.initialState, AuthenticationLoading());
  });

  test('dispose does not emit new states', () {
    expectLater(
      authenticationBloc.state,
      emitsInOrder([]),
    );
    authenticationBloc.dispose();
  });

  group('AppStarted', () {
    test(
        'emits [loading, unauthenticated] when user is not signed in initially',
        () {
      final expectedResponse = [
        AuthenticationLoading(),
        AuthenticationUnauthenticated(),
      ];

      when(mockFirebaseAuthService.getInitialSignInState())
          .thenAnswer((_) => null);

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(AppStarted());
    });

    test('emits [loading, authenticated] when user is signed in initially', () {
      final expectedResponse = [
        AuthenticationLoading(),
        AuthenticationAuthenticated(user: mockFirebaseUser),
      ];

      when(mockFirebaseAuthService.getInitialSignInState())
          .thenAnswer((_) => Future<MockFirebaseUser>.value(mockFirebaseUser));

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(AppStarted());
    });
  });

  group('LogIn', () {
    test('emits [loading, unauthenticated] when login is pressed and failed',
        () {
      final expectedResponse = [
        AuthenticationLoading(),
        AuthenticationUnauthenticated(),
      ];

      when(mockFirebaseAuthService.signInWithGoogle()).thenAnswer((_) => null);

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(Login());
    });

    test('emits [loading, authenticated] when login is pressed and successful',
        () {
      final expectedResponse = [
        AuthenticationLoading(),
        AuthenticationAuthenticated(user: mockFirebaseUser),
      ];

      when(mockFirebaseAuthService.signInWithGoogle())
          .thenAnswer((_) => Future<MockFirebaseUser>.value(mockFirebaseUser));

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(Login());
    });
  });

  group('LogOut', () {
    test('emits [loading, unauthenticated] when user signout', () {
      final expectedResponse = [
        AuthenticationLoading(),
        AuthenticationUnauthenticated(),
      ];

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(Logout());
    });
  });
}
