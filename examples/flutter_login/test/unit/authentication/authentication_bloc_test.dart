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
      'emits [unauthenticated] for invalid token',
      build: () async {
        when(userRepository.hasToken()).thenAnswer((_) => Future.value(false));
        return authenticationBloc;
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: [
        AuthenticationUnauthenticated(),
      ],
    );

    blocTest(
      'emits [authenticated] for valid token',
      build: () async {
        when(userRepository.hasToken()).thenAnswer((_) => Future.value(true));
        return authenticationBloc;
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: [
        AuthenticationAuthenticated(),
      ],
    );
  });

  group('LoggedIn', () {
    blocTest(
      'emits [loading, authenticated] when token is persisted',
      build: () async => authenticationBloc,
      act: (bloc) => bloc.add(LoggedIn(token: 'instance.token')),
      expect: [
        AuthenticationLoading(),
        AuthenticationAuthenticated(),
      ],
    );
  });

  group('LoggedOut', () {
    blocTest(
      'emits [loading, unauthenticated] when token is deleted',
      build: () async => authenticationBloc,
      act: (bloc) => bloc.add(LoggedOut()),
      expect: [
        AuthenticationLoading(),
        AuthenticationUnauthenticated(),
      ],
    );
  });
}
