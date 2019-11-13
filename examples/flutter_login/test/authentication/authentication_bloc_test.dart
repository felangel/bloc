import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  AuthenticationBloc authenticationBloc;
  MockUserRepository userRepository;

  setUp(() {
    userRepository = MockUserRepository();
    authenticationBloc = AuthenticationBloc(userRepository: userRepository);
  });

  tearDown(() {
    authenticationBloc?.close();
  });

  test('initial state is correct', () {
    expect(authenticationBloc.initialState, AuthenticationUninitialized());
  });

  test('close does not emit new states', () {
    expectLater(
      authenticationBloc,
      emitsInOrder([AuthenticationUninitialized(), emitsDone]),
    );
    authenticationBloc.close();
  });

  group('AppStarted', () {
    test('emits [uninitialized, unauthenticated] for invalid token', () {
      final expectedResponse = [
        AuthenticationUninitialized(),
        AuthenticationUnauthenticated()
      ];

      when(userRepository.hasToken()).thenAnswer((_) => Future.value(false));

      expectLater(
        authenticationBloc,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.add(AppStarted());
    });
  });

  group('LoggedIn', () {
    test(
        'emits [uninitialized, loading, authenticated] when token is persisted',
        () {
      final expectedResponse = [
        AuthenticationUninitialized(),
        AuthenticationLoading(),
        AuthenticationAuthenticated(),
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.add(LoggedIn(
        token: 'instance.token',
      ));
    });
  });

  group('LoggedOut', () {
    test(
        'emits [uninitialized, loading, unauthenticated] when token is deleted',
        () {
      final expectedResponse = [
        AuthenticationUninitialized(),
        AuthenticationLoading(),
        AuthenticationUnauthenticated(),
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.add(LoggedOut());
    });
  });
}
