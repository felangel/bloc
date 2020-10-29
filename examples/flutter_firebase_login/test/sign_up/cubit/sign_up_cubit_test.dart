// ignore_for_file: prefer_const_constructors
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_firebase_login/authentication/authentication.dart';
import 'package:flutter_firebase_login/sign_up/sign_up.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mockito/mockito.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  const invalidEmailString = 'invalid';
  const invalidEmail = Email.dirty(invalidEmailString);

  const validEmailString = 'test@gmail.com';
  const validEmail = Email.dirty(validEmailString);

  const invalidPasswordString = 'invalid';
  const invalidPassword = Password.dirty(invalidPasswordString);

  const validPasswordString = 't0pS3cret1234';
  const validPassword = Password.dirty(validPasswordString);

  const invalidConfirmedPasswordString = 'invalid';
  const invalidConfirmedPassword = ConfirmedPassword.dirty(
    password: validPasswordString,
    value: invalidConfirmedPasswordString,
  );

  const validConfirmedPasswordString = 't0pS3cret1234';
  const validConfirmedPassword = ConfirmedPassword.dirty(
    password: validPasswordString,
    value: validConfirmedPasswordString,
  );

  group('SignUpCubit', () {
    AuthenticationRepository authenticationRepository;

    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
    });

    test('throws AssertionError when authenticationRepository is null', () {
      expect(() => SignUpCubit(null), throwsA(isA<AssertionError>()));
    });

    test('initial state is SignUpState', () {
      expect(SignUpCubit(authenticationRepository).state, SignUpState());
    });

    group('emailChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.emailChanged(invalidEmailString),
        expect: const <SignUpState>[
          SignUpState(email: invalidEmail, status: FormzStatus.invalid),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: SignUpState(
          password: validPassword,
          confirmedPassword: validConfirmedPassword,
        ),
        act: (cubit) => cubit.emailChanged(validEmailString),
        expect: const <SignUpState>[
          SignUpState(
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );
    });

    group('passwordChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.passwordChanged(invalidPasswordString),
        expect: const <SignUpState>[
          SignUpState(
            confirmedPassword: ConfirmedPassword.dirty(
              password: invalidPasswordString,
              value: '',
            ),
            password: invalidPassword,
            status: FormzStatus.invalid,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: SignUpState(
          email: validEmail,
          confirmedPassword: validConfirmedPassword,
        ),
        act: (cubit) => cubit.passwordChanged(validPasswordString),
        expect: const <SignUpState>[
          SignUpState(
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );
    });

    group('confirmedPasswordChanged', () {
      blocTest<SignUpCubit, SignUpState>(
        'emits [invalid] when email/password/confirmedPassword are invalid',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) =>
            cubit.confirmedPasswordChanged(invalidConfirmedPasswordString),
        expect: const <SignUpState>[
          SignUpState(
            confirmedPassword: invalidConfirmedPassword,
            status: FormzStatus.invalid,
          ),
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [valid] when email/password/confirmedPassword are valid',
        build: () => SignUpCubit(authenticationRepository),
        seed: SignUpState(email: validEmail, password: validPassword),
        act: (cubit) => cubit.confirmedPasswordChanged(
          validConfirmedPasswordString,
        ),
        expect: const <SignUpState>[
          SignUpState(
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
            status: FormzStatus.valid,
          ),
        ],
      );
    });

    group('signUpFormSubmitted', () {
      blocTest<SignUpCubit, SignUpState>(
        'does nothing when status is not validated',
        build: () => SignUpCubit(authenticationRepository),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: const <SignUpState>[],
      );

      blocTest<SignUpCubit, SignUpState>(
        'calls signUp with correct email/password/confirmedPassword',
        build: () => SignUpCubit(authenticationRepository),
        seed: SignUpState(
          status: FormzStatus.valid,
          email: validEmail,
          password: validPassword,
          confirmedPassword: validConfirmedPassword,
        ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        verify: (_) {
          verify(
            authenticationRepository.signUp(
              email: validEmailString,
              password: validPasswordString,
            ),
          ).called(1);
        },
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [submissionInProgress, submissionSuccess] '
        'when signUp succeeds',
        build: () => SignUpCubit(authenticationRepository),
        seed: SignUpState(
          status: FormzStatus.valid,
          email: validEmail,
          password: validPassword,
          confirmedPassword: validConfirmedPassword,
        ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: const <SignUpState>[
          SignUpState(
            status: FormzStatus.submissionInProgress,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          ),
          SignUpState(
            status: FormzStatus.submissionSuccess,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          )
        ],
      );

      blocTest<SignUpCubit, SignUpState>(
        'emits [submissionInProgress, submissionFailure] '
        'when signUp fails',
        build: () {
          when(authenticationRepository.signUp(
            email: anyNamed('email'),
            password: anyNamed('password'),
          )).thenThrow(Exception('oops'));
          return SignUpCubit(authenticationRepository);
        },
        seed: SignUpState(
          status: FormzStatus.valid,
          email: validEmail,
          password: validPassword,
          confirmedPassword: validConfirmedPassword,
        ),
        act: (cubit) => cubit.signUpFormSubmitted(),
        expect: const <SignUpState>[
          SignUpState(
            status: FormzStatus.submissionInProgress,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          ),
          SignUpState(
            status: FormzStatus.submissionFailure,
            email: validEmail,
            password: validPassword,
            confirmedPassword: validConfirmedPassword,
          )
        ],
      );
    });
  });
}
