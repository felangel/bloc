// ignore_for_file: prefer_const_constructors
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_firebase_login/login/login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  const invalidEmail = 'invalid';
  const validEmail = 'test@gmail.com';
  const invalidPassword = 'invalid';
  const validPassword = 't0pS3cret1234';

  group('LoginCubit', () {
    late AuthenticationRepository authenticationRepository;

    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
      when(
        () => authenticationRepository.logInWithGoogle(),
      ).thenAnswer((_) async {});
      when(
        () => authenticationRepository.logInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});
    });

    test('initial state is LoginState', () {
      expect(LoginCubit(authenticationRepository).state, LoginState());
    });

    group('emailChanged', () {
      blocTest<LoginCubit, LoginState>(
        'emits [invalid] when email/password are invalid',
        build: () => LoginCubit(authenticationRepository),
        act: (cubit) => cubit.emailChanged(invalidEmail),
        expect: () => <LoginState>[LoginState().withEmail(invalidEmail)],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [valid] when email/password are valid',
        build: () => LoginCubit(authenticationRepository),
        seed: () => LoginState().withPassword(validPassword),
        act: (cubit) => cubit.emailChanged(validEmail),
        expect: () => <LoginState>[
          LoginState().withEmail(validEmail).withPassword(validPassword),
        ],
      );
    });

    group('passwordChanged', () {
      blocTest<LoginCubit, LoginState>(
        'emits [invalid] when email/password are invalid',
        build: () => LoginCubit(authenticationRepository),
        act: (cubit) => cubit.passwordChanged(invalidPassword),
        expect: () => <LoginState>[LoginState().withPassword(invalidPassword)],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [valid] when email/password are valid',
        build: () => LoginCubit(authenticationRepository),
        seed: () => LoginState().withEmail(validEmail),
        act: (cubit) => cubit.passwordChanged(validPassword),
        expect: () => <LoginState>[
          LoginState().withEmail(validEmail).withPassword(validPassword),
        ],
      );
    });

    group('logInWithCredentials', () {
      blocTest<LoginCubit, LoginState>(
        'does nothing when status is not validated',
        build: () => LoginCubit(authenticationRepository),
        act: (cubit) => cubit.logInWithCredentials(),
        expect: () => const <LoginState>[],
      );

      blocTest<LoginCubit, LoginState>(
        'calls logInWithEmailAndPassword with correct email/password',
        build: () => LoginCubit(authenticationRepository),
        seed: () {
          return LoginState().withEmail(validEmail).withPassword(validPassword);
        },
        act: (cubit) => cubit.logInWithCredentials(),
        verify: (_) {
          verify(
            () => authenticationRepository.logInWithEmailAndPassword(
              email: validEmail,
              password: validPassword,
            ),
          ).called(1);
        },
      );

      blocTest<LoginCubit, LoginState>(
        'emits [submissionInProgress, submissionSuccess] '
        'when logInWithEmailAndPassword succeeds',
        build: () => LoginCubit(authenticationRepository),
        seed: () {
          return LoginState().withEmail(validEmail).withPassword(validPassword);
        },
        act: (cubit) => cubit.logInWithCredentials(),
        expect: () => <LoginState>[
          LoginState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withSubmissionInProgress(),
          LoginState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withSubmissionSuccess(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [submissionInProgress, submissionFailure] '
        'when logInWithEmailAndPassword fails '
        'due to LogInWithEmailAndPasswordFailure',
        setUp: () {
          when(
            () => authenticationRepository.logInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(LogInWithEmailAndPasswordFailure('oops'));
        },
        build: () => LoginCubit(authenticationRepository),
        seed: () {
          return LoginState().withEmail(validEmail).withPassword(validPassword);
        },
        act: (cubit) => cubit.logInWithCredentials(),
        expect: () => <LoginState>[
          LoginState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withSubmissionInProgress(),
          LoginState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withSubmissionFailure('oops'),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [submissionInProgress, submissionFailure] '
        'when logInWithEmailAndPassword fails due to generic exception',
        setUp: () {
          when(
            () => authenticationRepository.logInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(Exception('oops'));
        },
        build: () => LoginCubit(authenticationRepository),
        seed: () {
          return LoginState().withEmail(validEmail).withPassword(validPassword);
        },
        act: (cubit) => cubit.logInWithCredentials(),
        expect: () => <LoginState>[
          LoginState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withSubmissionInProgress(),
          LoginState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withSubmissionFailure(),
        ],
      );
    });

    group('logInWithGoogle', () {
      blocTest<LoginCubit, LoginState>(
        'calls logInWithGoogle',
        build: () => LoginCubit(authenticationRepository),
        act: (cubit) => cubit.logInWithGoogle(),
        verify: (_) {
          verify(() => authenticationRepository.logInWithGoogle()).called(1);
        },
      );

      blocTest<LoginCubit, LoginState>(
        'emits [inProgress, success] '
        'when logInWithGoogle succeeds',
        build: () => LoginCubit(authenticationRepository),
        act: (cubit) => cubit.logInWithGoogle(),
        expect: () => <LoginState>[
          LoginState().withSubmissionInProgress(),
          LoginState().withSubmissionSuccess(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [inProgress, failure] '
        'when logInWithGoogle fails due to LogInWithGoogleFailure',
        setUp: () {
          when(
            () => authenticationRepository.logInWithGoogle(),
          ).thenThrow(LogInWithGoogleFailure('oops'));
        },
        build: () => LoginCubit(authenticationRepository),
        act: (cubit) => cubit.logInWithGoogle(),
        expect: () => <LoginState>[
          LoginState().withSubmissionInProgress(),
          LoginState().withSubmissionFailure('oops'),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [inProgress, failure] '
        'when logInWithGoogle fails due to generic exception',
        setUp: () {
          when(
            () => authenticationRepository.logInWithGoogle(),
          ).thenThrow(Exception('oops'));
        },
        build: () => LoginCubit(authenticationRepository),
        act: (cubit) => cubit.logInWithGoogle(),
        expect: () => <LoginState>[
          LoginState().withSubmissionInProgress(),
          LoginState().withSubmissionFailure(),
        ],
      );
    });
  });
}
