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
    blocTest(
      'emits [uninitialized, unauthenticated] for invalid token',
      build: () {
        when(userRepository.hasToken()).thenAnswer((_) => Future.value(false));
        return authenticationBloc;
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: [
        AuthenticationUninitialized(),
        AuthenticationUnauthenticated(),
      ],
    );

    blocTest(
      'emits [uninitialized, authenticated] for valid token',
      build: () {
        when(userRepository.hasToken()).thenAnswer((_) => Future.value(true));
        return authenticationBloc;
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: [
        AuthenticationUninitialized(),
        AuthenticationAuthenticated(),
      ],
    );
  });

  group('LoggedIn', () {
    blocTest(
      'emits [uninitialized, loading, authenticated] when token is persisted',
      build: () => authenticationBloc,
      act: (bloc) => bloc.add(LoggedIn(token: 'instance.token')),
      expect: [
        AuthenticationUninitialized(),
        AuthenticationLoading(),
        AuthenticationAuthenticated(),
      ],
    );
  });

  group('LoggedOut', () {
    blocTest(
      'emits [uninitialized, loading, unauthenticated] when token is deleted',
      build: () => authenticationBloc,
      act: (bloc) => bloc.add(LoggedOut()),
      expect: [
        AuthenticationUninitialized(),
        AuthenticationLoading(),
        AuthenticationUnauthenticated(),
      ],
    );
  });
}
