import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  const user = User('id');
  AuthenticationRepository authenticationRepository;

  setUp(() {
    authenticationRepository = MockAuthenticationRepository();
    when(authenticationRepository.user).thenAnswer((_) => const Stream.empty());
  });

  group('AuthenticationBloc', () {
    test('throws when authenticationRepository is null', () {
      expect(
        () => AuthenticationBloc(authenticationRepository: null),
        throwsAssertionError,
      );
    });

    test('initial state is AuthenticationState,initial', () {
      final authenticationBloc = AuthenticationBloc(
        authenticationRepository: authenticationRepository,
      );
      expect(authenticationBloc.state, const AuthenticationState.initial());
      authenticationBloc.close();
    });

    blocTest(
      'emits [unauthenticated] when no user is present',
      build: () {
        when(authenticationRepository.user)
            .thenAnswer((_) => Stream.value(null));
        return AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        );
      },
      expect: [const AuthenticationState.unauthenticated()],
    );

    blocTest(
      'emits [authenticated] when user is present',
      build: () {
        when(authenticationRepository.user)
            .thenAnswer((_) => Stream.value(user));
        return AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        );
      },
      expect: [const AuthenticationState.authenticated(user)],
    );
  });

  group('UserChanged', () {
    blocTest(
      'emits [authenticated] when user is present',
      build: () {
        when(authenticationRepository.user).thenAnswer(
          (_) => Stream.value(user),
        );
        return AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        );
      },
      act: (bloc) => bloc.add(const UserChanged(user)),
      expect: [const AuthenticationState.authenticated(user)],
    );
  });

  group('LoggedOut', () {
    blocTest(
      'emits [unauthenticated]',
      build: () {
        when(authenticationRepository.user).thenAnswer(
          (_) => const Stream.empty(),
        );
        return AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        );
      },
      act: (bloc) => bloc.add(const UserChanged(null)),
      expect: [const AuthenticationState.unauthenticated()],
    );

    blocTest(
      'calls logOut on authenticationRepository '
      'when LoggedOut is added',
      build: () {
        when(authenticationRepository.user).thenAnswer(
          (_) => const Stream.empty(),
        );
        return AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        );
      },
      act: (bloc) => bloc.add(LoggedOut()),
      verify: (_) {
        verify(authenticationRepository.logOut()).called(1);
      },
    );
  });
}
