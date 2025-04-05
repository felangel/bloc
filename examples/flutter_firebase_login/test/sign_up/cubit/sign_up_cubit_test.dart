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
        expect: () => <SignUpState>[SignUpState().withEmail(invalidEmail)],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState()
            .withPassword(validPassword)
            .withConfirmedPassword(validConfirmedPassword),
        act: (cubit) => cubit.emailChanged(validEmail),
        expect: () => <SignUpState>[
          SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validConfirmedPassword),
        ],
      );
    });

    group('passwordChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.passwordChanged(invalidPassword),
        expect: () => <SignUpState>[
          SignUpState().withPassword(invalidPassword),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState()
            .withEmail(validEmail)
            .withConfirmedPassword(validConfirmedPassword),
        act: (cubit) => cubit.passwordChanged(validPassword),
        expect: () => <SignUpState>[
          SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validConfirmedPassword),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when confirmedPasswordChanged is called first and then '
        'passwordChanged is called',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState().withEmail(validEmail),
        act: (cubit) => cubit
          ..confirmedPasswordChanged(validConfirmedPassword)
          ..passwordChanged(validPassword),
        expect: () => <SignUpState>[
          SignUpState()
              .withEmail(validEmail)
              .withConfirmedPassword(validConfirmedPassword),
          SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validConfirmedPassword),
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
          SignUpState().withConfirmedPassword(invalidConfirmedPassword),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: () {
          return SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword);
        },
        act: (cubit) => cubit.confirmedPasswordChanged(validConfirmedPassword),
        expect: () => <SignUpState>[
          SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validConfirmedPassword),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when passwordChanged is called first and then '
        'confirmedPasswordChanged is called',
        build: () => SignUpCubit(authenticationRepository),
        seed: () => SignUpState().withEmail(validEmail),
        act: (cubit) => cubit
          ..passwordChanged(validPassword)
          ..confirmedPasswordChanged(validConfirmedPassword),
        expect: () => <SignUpState>[
          SignUpState().withEmail(validEmail).withPassword(validPassword),
          SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validConfirmedPassword),
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
            .withEmail(validEmail)
            .withPassword(validPassword)
            .withConfirmedPassword(validConfirmedPassword),
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
            .withEmail(validEmail)
            .withPassword(validPassword)
            .withConfirmedPassword(validConfirmedPassword),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => <SignUpState>[
          SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validConfirmedPassword)
              .withSubmissionInProgress(),
          SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validConfirmedPassword)
              .withSubmissionSuccess(),
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
            .withEmail(validEmail)
            .withPassword(validPassword)
            .withConfirmedPassword(validConfirmedPassword),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => <SignUpState>[
          SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validConfirmedPassword)
              .withSubmissionInProgress(),
          SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validConfirmedPassword)
              .withSubmissionFailure('oops'),
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
            .withEmail(validEmail)
            .withPassword(validPassword)
            .withConfirmedPassword(validConfirmedPassword),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: () => <SignUpState>[
          SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validConfirmedPassword)
              .withSubmissionInProgress(),
          SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validConfirmedPassword)
              .withSubmissionFailure(),
        ],
      );
    });
  });
}
