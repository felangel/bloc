import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  const user = User('id');
  AuthenticationBloc authenticationBloc;
  MockUserRepository userRepository;

  setUp(() {
    userRepository = MockUserRepository();
    when(userRepository.userStream()).thenAnswer((_) => const Stream.empty());
    authenticationBloc = AuthenticationBloc(userRepository: userRepository);
  });

  tearDown(() {
    authenticationBloc?.close();
  });

  group('AuthenticationBloc', () {
    test('throws when userRepository is null', () {
      expect(
        () => AuthenticationBloc(userRepository: null),
        throwsAssertionError,
      );
    });

    test('initial state is AuthenticationInProgress', () {
      expect(authenticationBloc.state, const AuthenticationInProgress());
    });

    blocTest(
      'emits [AuthenticationUnauthenticated] when no user present',
      build: () async {
        when(userRepository.userStream()).thenAnswer((_) => Stream.value(null));
        return AuthenticationBloc(userRepository: userRepository);
      },
      expect: [const AuthenticationUnauthenticated()],
    );

    blocTest(
      'emits [AuthenticationAuthenticated] when user present',
      build: () async {
        when(userRepository.userStream()).thenAnswer((_) => Stream.value(user));
        return AuthenticationBloc(userRepository: userRepository);
      },
      expect: [const AuthenticationAuthenticated(user)],
    );
  });

  group('UserChanged', () {
    blocTest(
      'emits [AuthenticationAuthenticated] when user is present',
      build: () async {
        when(userRepository.userStream()).thenAnswer((_) => Stream.value(user));
        return AuthenticationBloc(userRepository: userRepository);
      },
      act: (bloc) async => bloc.add(const UserChanged(user)),
      expect: [const AuthenticationAuthenticated(user)],
    );
  });

  group('LoggedOut', () {
    blocTest(
      'emits [AuthenticationInProgress, AuthenticationFailure] '
      'when logging out',
      build: () async {
        when(userRepository.userStream()).thenAnswer(
          (_) => const Stream.empty(),
        );
        return AuthenticationBloc(userRepository: userRepository);
      },
      act: (bloc) async => bloc.add(const UserChanged(null)),
      expect: [const AuthenticationUnauthenticated()],
    );

    blocTest(
      'calls logOut on userRepository '
      'when LoggedOut is added',
      build: () async {
        when(userRepository.userStream()).thenAnswer(
          (_) => const Stream.empty(),
        );
        return AuthenticationBloc(userRepository: userRepository);
      },
      act: (bloc) async => bloc.add(LoggedOut()),
      verify: (_) async {
        verify(userRepository.logOut()).called(1);
      },
    );
  });
}
