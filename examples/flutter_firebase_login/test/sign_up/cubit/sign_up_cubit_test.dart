// ignore_for_file: prefer_const_constructors
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_firebase_login/sign_up/sign_up.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  const invalidEmail = 'invalid';
  const validEmail = 'test@gmail.com';
  const invalidPassword = 'invalid';
  const validPassword = 't0pS3cret1234';
  const invalidConfirmedPassword = 'invalid';
  const validConfirmedPassword = 't0pS3cret1234';

  group('SignUpCubit', () {
    late AuthenticationRepository authenticationRepository;

    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
      when(
        () => authenticationRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});
    });

    test('initial state is SignUpState', () {
      expect(
        SignUpCubit(authenticationRepository).state,
        SignUpState(),
      );
    });

    group('emailChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.emailChanged(invalidEmail),
        expect: () => <SignUpState>[
          SignUpState().dirtyEmail(invalidEmail),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState()
            .dirtyPassword(validPassword)
            .dirtyConfirmedPassword(validConfirmedPassword),
        act: (cubit) => cubit.emailChanged(validEmail),
        expect: () => <SignUpState>[
          SignUpState()
              .dirtyEmail(validEmail)
              .dirtyPassword(validPassword)
              .dirtyConfirmedPassword(validConfirmedPassword),
        ],
      );
    });

    group('passwordChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.passwordChanged(invalidPassword),
        expect: () => <SignUpState>[
          SignUpState().dirtyPassword(invalidPassword),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState()
            .dirtyEmail(validEmail)
            .dirtyConfirmedPassword(validConfirmedPassword),
        act: (cubit) => cubit.passwordChanged(validPassword),
        expect: () => <SignUpState>[
          SignUpState()
              .dirtyEmail(validEmail)
              .dirtyPassword(validPassword)
              .dirtyConfirmedPassword(validConfirmedPassword),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when confirmedPasswordChanged is called first and then '
        'passwordChanged is called',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState().dirtyEmail(validEmail),
        act: (cubit) => cubit
          ..confirmedPasswordChanged(validConfirmedPassword)
          ..passwordChanged(validPassword),
        expect: () => <SignUpState>[
          SignUpState()
              .dirtyEmail(validEmail)
              .dirtyConfirmedPassword(validConfirmedPassword),
          SignUpState()
              .dirtyEmail(validEmail)
              .dirtyPassword(validPassword)
              .dirtyConfirmedPassword(validConfirmedPassword),
        ],
      );
    });

    group('confirmedPasswordChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) {
          cubit.confirmedPasswordChanged(invalidConfirmedPassword);
        },
        expect: () => <SignUpState>[
          SignUpState().dirtyConfirmedPassword(
            invalidConfirmedPassword,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () =>
            SignUpState().dirtyEmail(validEmail).dirtyPassword(validPassword),
        act: (cubit) => cubit.confirmedPasswordChanged(
          validConfirmedPassword,
        ),
        expect: () => <SignUpState>[
          SignUpState()
              .dirtyEmail(validEmail)
              .dirtyPassword(validPassword)
              .dirtyConfirmedPassword(validConfirmedPassword),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when passwordChanged is called first and then '
        'confirmedPasswordChanged is called',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState().dirtyEmail(validEmail),
        act: (cubit) => cubit
          ..passwordChanged(validPassword)
          ..confirmedPasswordChanged(validConfirmedPassword),
        expect: () => <SignUpState>[
          SignUpState().dirtyEmail(validEmail).dirtyPassword(validPassword),
          SignUpState()
              .dirtyEmail(validEmail)
              .dirtyPassword(validPassword)
              .dirtyConfirmedPassword(validConfirmedPassword),
        ],
      );
    });

    group('signUpFormSubmitted', () {
      blocTest<SignUpCubit, SignUpState>(
        'does nothing when status is not validated',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => const <SignUpState>[],
      );

      blocTest<SignUpCubit, SignUpState>(
        'calls signUp with correct email/password/confirmedPassword',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState()
            .dirtyEmail(validEmail)
            .dirtyPassword(validPassword)
            .dirtyConfirmedPassword(validConfirmedPassword),
        act: (cubit) => cubit.signUpFormSubmitted(),
        verify: (_) {
          verify(
            () => authenticationRepository.signUp(
              email: validEmail,
              password: validPassword,
            ),
          ).called(1);
        },
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [inProgress, success] '
        'when signUp succeeds',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState()
            .dirtyEmail(validEmail)
            .dirtyPassword(validPassword)
            .dirtyConfirmedPassword(validConfirmedPassword),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => <SignUpState>[
          SignUpState()
              .dirtyEmail(validEmail)
              .dirtyPassword(validPassword)
              .dirtyConfirmedPassword(validConfirmedPassword)
              .submissionInProgress(),
          SignUpState()
              .dirtyEmail(validEmail)
              .dirtyPassword(validPassword)
              .dirtyConfirmedPassword(validConfirmedPassword)
              .submissionSuccess(),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [inProgress, failure] '
        'when signUp fails due to SignUpWithEmailAndPasswordFailure',
        setUp: () {
          when(
            () => authenticationRepository.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(SignUpWithEmailAndPasswordFailure('oops'));
        },
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState()
            .dirtyEmail(validEmail)
            .dirtyPassword(validPassword)
            .dirtyConfirmedPassword(validConfirmedPassword),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => <SignUpState>[
          SignUpState()
              .dirtyEmail(validEmail)
              .dirtyPassword(validPassword)
              .dirtyConfirmedPassword(validConfirmedPassword)
              .submissionInProgress(),
          SignUpState()
              .dirtyEmail(validEmail)
              .dirtyPassword(validPassword)
              .dirtyConfirmedPassword(validConfirmedPassword)
              .submissionFailure('oops'),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [inProgress, failure] '
        'when signUp fails due to generic exception',
        setUp: () {
          when(
            () => authenticationRepository.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(Exception('oops'));
        },
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState()
            .dirtyEmail(validEmail)
            .dirtyPassword(validPassword)
            .dirtyConfirmedPassword(validConfirmedPassword),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => <SignUpState>[
          SignUpState()
              .dirtyEmail(validEmail)
              .dirtyPassword(validPassword)
              .dirtyConfirmedPassword(validConfirmedPassword)
              .submissionInProgress(),
          SignUpState()
              .dirtyEmail(validEmail)
              .dirtyPassword(validPassword)
              .dirtyConfirmedPassword(validConfirmedPassword)
              .submissionFailure(),
        ],
      );
    });
  });
}
