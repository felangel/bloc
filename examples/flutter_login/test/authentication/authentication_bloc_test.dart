import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class _MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class _MockUserRepository extends Mock implements UserRepository {}

void main() {
  const user = User('id');
  late AuthenticationRepository authenticationRepository;
  late UserRepository userRepository;

  setUp(() {
    authenticationRepository = _MockAuthenticationRepository();
    when(
      () => authenticationRepository.status,
    ).thenAnswer((_) => const Stream.empty());
    userRepository = _MockUserRepository();
  });

  AuthenticationBloc buildBloc() {
    return AuthenticationBloc(
      authenticationRepository: authenticationRepository,
      userRepository: userRepository,
    );
  }

  group('AuthenticationBloc', () {
    test('initial state is AuthenticationState.unknown', () {
      final authenticationBloc = buildBloc();
      expect(authenticationBloc.state, const AuthenticationState.unknown());
      authenticationBloc.close();
    });

    group('AuthenticationSubscriptionRequested', () {
      final error = Exception('oops');

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [unauthenticated] when status is unauthenticated',
        setUp: () {
          when(() => authenticationRepository.status).thenAnswer(
            (_) => Stream.value(AuthenticationStatus.unauthenticated),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        expect: () => const [AuthenticationState.unauthenticated()],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [authenticated] when status is authenticated',
        setUp: () {
          when(() => authenticationRepository.status).thenAnswer(
            (_) => Stream.value(AuthenticationStatus.authenticated),
          );
          when(() => userRepository.getUser()).thenAnswer((_) async => user);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        expect: () => const [AuthenticationState.authenticated(user)],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [authenticated] when status is authenticated',
        setUp: () {
          when(
            () => authenticationRepository.status,
          ).thenAnswer((_) => Stream.value(AuthenticationStatus.authenticated));
          when(() => userRepository.getUser()).thenAnswer((_) async => user);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        expect: () => const [AuthenticationState.authenticated(user)],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [unauthenticated] when status is unauthenticated',
        setUp: () {
          when(() => authenticationRepository.status).thenAnswer(
            (_) => Stream.value(AuthenticationStatus.unauthenticated),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        expect: () => const [AuthenticationState.unauthenticated()],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [unauthenticated] when status is authenticated '
        'but getUser fails',
        setUp: () {
          when(
            () => authenticationRepository.status,
          ).thenAnswer((_) => Stream.value(AuthenticationStatus.authenticated));
          when(() => userRepository.getUser()).thenThrow(Exception('oops'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        expect: () => const [AuthenticationState.unauthenticated()],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [unauthenticated] when status is authenticated '
        'but getUser returns null',
        setUp: () {
          when(
            () => authenticationRepository.status,
          ).thenAnswer((_) => Stream.value(AuthenticationStatus.authenticated));
          when(() => userRepository.getUser()).thenAnswer((_) async => null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        expect: () => const [AuthenticationState.unauthenticated()],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [unknown] when status is unknown',
        setUp: () {
          when(
            () => authenticationRepository.status,
          ).thenAnswer((_) => Stream.value(AuthenticationStatus.unknown));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        expect: () => const [AuthenticationState.unknown()],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'adds error when status stream emits an error',
        setUp: () {
          when(
            () => authenticationRepository.status,
          ).thenAnswer((_) => Stream.error(error));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AuthenticationSubscriptionRequested()),
        errors: () => [error],
      );
    });
  });

  group('AuthenticationLogoutPressed', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'calls logOut on authenticationRepository ',
      build: buildBloc,
      act: (bloc) => bloc.add(AuthenticationLogoutPressed()),
      verify: (_) {
        verify(() => authenticationRepository.logOut()).called(1);
      },
    );
  });
}
