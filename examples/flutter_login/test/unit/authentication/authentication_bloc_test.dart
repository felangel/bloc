import 'package:bloc_test/bloc_test.dart';
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

  test('throws AssertionError when userRepository is null', () {
    expect(
      () => AuthenticationBloc(userRepository: null),
      throwsAssertionError,
    );
  });

  test('initial state is correct', () {
    expect(authenticationBloc.state, AuthenticationInitial());
  });

  test('close does not emit new states', () {
    expectLater(
      authenticationBloc,
      emitsInOrder([AuthenticationInitial(), emitsDone]),
    );
    authenticationBloc.close();
  });

  group('AppStarted', () {
    blocTest(
      'emits [unauthenticated] for invalid token',
      build: () async {
        when(userRepository.hasToken()).thenAnswer((_) => Future.value(false));
        return authenticationBloc;
      },
      act: (bloc) => bloc.add(AuthenticationStarted()),
      expect: [
        AuthenticationFailure(),
      ],
    );

    blocTest(
      'emits [authenticated] for valid token',
      build: () async {
        when(userRepository.hasToken()).thenAnswer((_) => Future.value(true));
        return authenticationBloc;
      },
      act: (bloc) => bloc.add(AuthenticationStarted()),
      expect: [
        AuthenticationSuccess(),
      ],
    );
  });

  group('LoggedIn', () {
    blocTest(
      'emits [loading, authenticated] when token is persisted',
      build: () async => authenticationBloc,
      act: (bloc) => bloc.add(AuthenticationLoggedIn(token: 'instance.token')),
      expect: [
        AuthenticationInProgress(),
        AuthenticationSuccess(),
      ],
    );
  });

  group('LoggedOut', () {
    blocTest(
      'emits [loading, unauthenticated] when token is deleted',
      build: () async => authenticationBloc,
      act: (bloc) => bloc.add(AuthenticationLoggedOut()),
      expect: [
        AuthenticationInProgress(),
        AuthenticationFailure(),
      ],
    );
  });
}
