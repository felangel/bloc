// ignore_for_file: prefer_const_constructors
import 'package:flutter_firebase_login/login/login.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const email = 'test@gmail.com';
  const password = 'Test1234';

  group('LoginState', () {
    test('supports value comparisons', () {
      expect(LoginState.initial(), LoginState.initial());
    });

    group('isValid', () {
      test('is false for initial state', () {
        expect(LoginState.initial().isValid, isFalse);
      });

      test('is true when validation succeeds', () {
        expect(
          LoginState.initial()
              .dirtyEmail(email)
              .dirtyPassword(password)
              .isValid,
          isTrue,
        );
      });
    });
  });
}
