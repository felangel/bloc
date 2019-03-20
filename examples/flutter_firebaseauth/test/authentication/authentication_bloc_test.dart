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
    expect(authenticationBloc.initialState, AuthenticationUninitialized());
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
        'emits [uninitialized, unauthenticated] when user is not signed in initially',
        () {
      final expectedResponse = [
        AuthenticationUninitialized(),
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

    test(
        'emits [uninitialized, authenticated] when user is signed in initially',
        () {
      final expectedResponse = [
        AuthenticationUninitialized(),
        AuthenticationAuthenticated(),
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
    test(
        'emits [uninitialized, loading, unauthenticated] when login is pressed and failed',
        () {
      final expectedResponse = [
        AuthenticationUninitialized(),
        AuthenticationLoading(),
        AuthenticationUnauthenticated(),
      ];

      when(mockFirebaseAuthService.sigInWithGoogle()).thenAnswer((_) => null);

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(LogIn());
    });

    test(
        'emits [uninitialized, loading, authenticated] when login is pressed and successful',
        () {
      final expectedResponse = [
        AuthenticationUninitialized(),
        AuthenticationLoading(),
        AuthenticationAuthenticated(),
      ];

      when(mockFirebaseAuthService.sigInWithGoogle())
          .thenAnswer((_) => Future<MockFirebaseUser>.value(mockFirebaseUser));

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(LogIn());
    });
  });

  group('LogOut', () {
    test('emits [uninitialized, loading, unauthenticated] when user signout',
        () {
      final expectedResponse = [
        AuthenticationUninitialized(),
        AuthenticationLoading(),
        AuthenticationUnauthenticated(),
      ];

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(LogOut());
    });
  });
}
