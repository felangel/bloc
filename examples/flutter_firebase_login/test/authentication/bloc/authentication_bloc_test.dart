import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_firebase_login/authentication/authentication.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

// ignore: must_be_immutable
class MockUser extends Mock implements User {}

void main() {
  final user = MockUser();
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

    test('initial state is AuthenticationState.unknown', () {
      final authenticationBloc = AuthenticationBloc(
        authenticationRepository: authenticationRepository,
      );
      expect(authenticationBloc.state, const AuthenticationState.unknown());
      authenticationBloc.close();
    });

    blocTest<AuthenticationBloc, AuthenticationState>(
      'subscribes to user stream',
      build: () {
        when(authenticationRepository.user).thenAnswer(
          (_) => Stream.value(user),
        );
        return AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        );
      },
      expect: <AuthenticationState>[
        AuthenticationState.authenticated(user),
      ],
    );

    group('AuthenticationUserChanged', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [authenticated] when user is not null',
        build: () => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        ),
        act: (bloc) => bloc.add(AuthenticationUserChanged(user)),
        expect: <AuthenticationState>[
          AuthenticationState.authenticated(user),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [unauthenticated] when user is empty',
        build: () => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        ),
        act: (bloc) => bloc.add(const AuthenticationUserChanged(User.empty)),
        expect: const <AuthenticationState>[
          AuthenticationState.unauthenticated(),
        ],
      );
    });

    group('AuthenticationLogoutRequested', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'calls logOut on authenticationRepository '
        'when AuthenticationLogoutRequested is added',
        build: () => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        ),
        act: (bloc) => bloc.add(AuthenticationLogoutRequested()),
        verify: (_) {
          verify(authenticationRepository.logOut()).called(1);
        },
      );
    });
  });
}
