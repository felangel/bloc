import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication/authentication.dart';
import 'package:flutter_firebase_login/sign_up/sign_up.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mockito/mockito.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockSignUpCubit extends MockBloc<SignUpState> implements SignUpCubit {}

class MockEmail extends Mock implements Email {}

class MockPassword extends Mock implements Password {}

void main() {
  const signUpButtonKey = Key('signUpForm_continue_raisedButton');
  const emailInputKey = Key('signUpForm_emailInput_textField');
  const passwordInputKey = Key('signUpForm_passwordInput_textField');

  const testEmail = 'test@gmail.com';
  const testPassword = 'testP@ssw0rd1';

  group('SignUpForm', () {
    SignUpCubit signUpCubit;

    setUp(() {
      signUpCubit = MockSignUpCubit();
      when(signUpCubit.state).thenReturn(const SignUpState());
    });

    group('calls', () {
      testWidgets('emailChanged when email changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: SignUpForm(),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(emailInputKey), testEmail);
        verify(signUpCubit.emailChanged(testEmail)).called(1);
      });

      testWidgets('passwordChanged when password changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: SignUpForm(),
              ),
            ),
          ),
        );
        await tester.enterText(find.byKey(passwordInputKey), testPassword);
        verify(signUpCubit.passwordChanged(testPassword)).called(1);
      });

      testWidgets('signUpFormSubmitted when sign up button is pressed',
          (tester) async {
        when(signUpCubit.state).thenReturn(
          const SignUpState(status: FormzStatus.valid),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: SignUpForm(),
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(signUpButtonKey));
        verify(signUpCubit.signUpFormSubmitted()).called(1);
      });
    });

    group('renders', () {
      testWidgets('Sign Up Failure SnackBar when submission fails',
          (tester) async {
        whenListen(
          signUpCubit,
          Stream.fromIterable(const <SignUpState>[
            SignUpState(status: FormzStatus.submissionInProgress),
            SignUpState(status: FormzStatus.submissionFailure),
          ]),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: SignUpForm(),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Sign Up Failure'), findsOneWidget);
      });

      testWidgets('invalid email error text when email is invalid',
          (tester) async {
        final email = MockEmail();
        when(email.invalid).thenReturn(true);
        when(signUpCubit.state).thenReturn(SignUpState(email: email));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: SignUpForm(),
              ),
            ),
          ),
        );
        expect(find.text('invalid email'), findsOneWidget);
      });

      testWidgets('invalid password error text when password is invalid',
          (tester) async {
        final password = MockPassword();
        when(password.invalid).thenReturn(true);
        when(signUpCubit.state).thenReturn(SignUpState(password: password));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: SignUpForm(),
              ),
            ),
          ),
        );
        expect(find.text('invalid password'), findsOneWidget);
      });

      testWidgets('disabled sign up button when status is not validated',
          (tester) async {
        when(signUpCubit.state).thenReturn(
          const SignUpState(status: FormzStatus.invalid),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: SignUpForm(),
              ),
            ),
          ),
        );
        final signUpButton = tester.widget<RaisedButton>(
          find.byKey(signUpButtonKey),
        );
        expect(signUpButton.enabled, isFalse);
      });

      testWidgets('enabled sign up button when status is validated',
          (tester) async {
        when(signUpCubit.state).thenReturn(
          const SignUpState(status: FormzStatus.valid),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: signUpCubit,
                child: SignUpForm(),
              ),
            ),
          ),
        );
        final signUpButton = tester.widget<RaisedButton>(
          find.byKey(signUpButtonKey),
        );
        expect(signUpButton.enabled, isTrue);
      });
    });
  });
}
