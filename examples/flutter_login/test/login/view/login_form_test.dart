// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/login/login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

void main() {
  group('LoginForm', () {
    late LoginBloc loginBloc;

    setUp(() {
      loginBloc = MockLoginBloc();
    });

    testWidgets(
        'adds LoginUsernameChanged to LoginBloc when username is updated',
        (tester) async {
      const username = 'username';
      when(() => loginBloc.state).thenReturn(const LoginState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const Key('loginForm_usernameInput_textField')),
        username,
      );
      verify(
        () => loginBloc.add(const LoginUsernameChanged(username)),
      ).called(1);
    });

    testWidgets(
        'adds LoginPasswordChanged to LoginBloc when password is updated',
        (tester) async {
      const password = 'password';
      when(() => loginBloc.state).thenReturn(const LoginState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const Key('loginForm_passwordInput_textField')),
        password,
      );
      verify(
        () => loginBloc.add(const LoginPasswordChanged(password)),
      ).called(1);
    });

    testWidgets('continue button is disabled by default', (tester) async {
      when(() => loginBloc.state).thenReturn(const LoginState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isFalse);
    });

    testWidgets(
        'loading indicator is shown when status is submission in progress',
        (tester) async {
      when(() => loginBloc.state).thenReturn(
        const LoginState(status: FormzStatus.submissionInProgress),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('continue button is enabled when status is validated',
        (tester) async {
      when(() => loginBloc.state).thenReturn(
        const LoginState(status: FormzStatus.valid),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isTrue);
    });

    testWidgets('LoginSubmitted is added to LoginBloc when continue is tapped',
        (tester) async {
      when(() => loginBloc.state).thenReturn(
        const LoginState(status: FormzStatus.valid),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      verify(() => loginBloc.add(const LoginSubmitted())).called(1);
    });

    testWidgets('shows SnackBar when status is submission failure',
        (tester) async {
      whenListen(
        loginBloc,
        Stream.fromIterable([
          const LoginState(status: FormzStatus.submissionInProgress),
          const LoginState(status: FormzStatus.submissionFailure),
        ]),
      );
      when(() => loginBloc.state).thenReturn(
        const LoginState(status: FormzStatus.submissionFailure),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: loginBloc,
              child: LoginForm(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
