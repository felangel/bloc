import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/sign_up/sign_up.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSignUpCubit extends MockCubit<SignUpState> implements SignUpCubit {}

void main() {
  const signUpButtonKey = Key('signUpForm_continue_raisedButton');
  const emailInputKey = Key('signUpForm_emailInput_textField');
  const passwordInputKey = Key('signUpForm_passwordInput_textField');
  const confirmedPasswordInputKey =
      Key('signUpForm_confirmedPasswordInput_textField');

  const validEmail = 'test@gmail.com';
  const validPassword = 'Test1234';
  const invalidEmail = 'invalid';
  const invalidPassword = 'invalid';

  group('SignUpForm', () {
    late SignUpCubit signUpCubit;

    setUp(() {
      signUpCubit = MockSignUpCubit();
      when(() => signUpCubit.state).thenReturn(const SignUpState());
      when(() => signUpCubit.signUpFormSubmitted()).thenAnswer((_) async {});
    });

    group('calls', () {
      testWidgets('emailChanged when email changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: const SignUpForm(),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(emailInputKey), validEmail);
        verify(() => signUpCubit.emailChanged(validEmail)).called(1);
      });

      testWidgets('passwordChanged when password changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: const SignUpForm(),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(passwordInputKey), validPassword);
        verify(() => signUpCubit.passwordChanged(validPassword)).called(1);
      });

      testWidgets('confirmedPasswordChanged when confirmedPassword changes',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: const SignUpForm(),
              ),
            ),
          ),
        );
        await tester.enterText(
          find.byKey(confirmedPasswordInputKey),
          validPassword,
        );
        verify(
          () => signUpCubit.confirmedPasswordChanged(validPassword),
        ).called(1);
      });

      testWidgets('signUpFormSubmitted when sign up button is pressed',
          (tester) async {
        when(() => signUpCubit.state).thenReturn(
          const SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validPassword),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: const SignUpForm(),
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(signUpButtonKey));
        verify(() => signUpCubit.signUpFormSubmitted()).called(1);
      });
    });

    group('renders', () {
      testWidgets('Sign Up Failure SnackBar when submission fails',
          (tester) async {
        whenListen(
          signUpCubit,
          Stream.fromIterable(<SignUpState>[
            const SignUpState(),
            const SignUpState().withSubmissionFailure(),
          ]),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: const SignUpForm(),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Sign Up Failure'), findsOneWidget);
      });

      testWidgets('invalid email error text when email is invalid',
          (tester) async {
        when(() => signUpCubit.state).thenReturn(
          const SignUpState()
              .withEmail(invalidEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validPassword),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: const SignUpForm(),
              ),
            ),
          ),
        );
        expect(find.text('invalid email'), findsOneWidget);
      });

      testWidgets('invalid password error text when password is invalid',
          (tester) async {
        when(() => signUpCubit.state).thenReturn(
          const SignUpState()
              .withEmail(validEmail)
              .withPassword(invalidPassword),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: const SignUpForm(),
              ),
            ),
          ),
        );
        expect(find.text('invalid password'), findsOneWidget);
      });

      testWidgets(
          'invalid confirmedPassword error text'
          ' when confirmedPassword is invalid', (tester) async {
        when(() => signUpCubit.state).thenReturn(
          const SignUpState().withConfirmedPassword(invalidPassword),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: const SignUpForm(),
              ),
            ),
          ),
        );
        expect(find.text('passwords do not match'), findsOneWidget);
      });

      testWidgets('disabled sign up button when status is not validated',
          (tester) async {
        when(() => signUpCubit.state).thenReturn(const SignUpState());
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: const SignUpForm(),
              ),
            ),
          ),
        );
        final signUpButton = tester.widget<ElevatedButton>(
          find.byKey(signUpButtonKey),
        );
        expect(signUpButton.enabled, isFalse);
      });

      testWidgets('enabled sign up button when status is validated',
          (tester) async {
        when(() => signUpCubit.state).thenReturn(
          const SignUpState()
              .withEmail(validEmail)
              .withPassword(validPassword)
              .withConfirmedPassword(validPassword),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: const SignUpForm(),
              ),
            ),
          ),
        );
        final signUpButton = tester.widget<ElevatedButton>(
          find.byKey(signUpButtonKey),
        );
        expect(signUpButton.enabled, isTrue);
      });
    });

    group('navigates', () {
      testWidgets('back to previous page when submission status is success',
          (tester) async {
        whenListen(
          signUpCubit,
          Stream.fromIterable(<SignUpState>[
            const SignUpState()
                .withEmail(validEmail)
                .withPassword(validPassword)
                .withConfirmedPassword(validPassword)
                .withSubmissionInProgress(),
            const SignUpState()
                .withEmail(validEmail)
                .withPassword(validPassword)
                .withConfirmedPassword(validPassword)
                .withSubmissionSuccess(),
          ]),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: const SignUpForm(),
              ),
            ),
          ),
        );
        expect(find.byType(SignUpForm), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byType(SignUpForm), findsNothing);
      });
    });
  });
}
