// ignore_for_file: prefer_const_constructors
import 'package:flutter_firebase_login/sign_up/sign_up.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const email = 'test@gmail.com';
  const password = 'Test1234';

  group('SignUpState', () {
    test('supports value comparisons', () {
      expect(SignUpState(), SignUpState());
    });

    group('isValid', () {
      test('is false for initial state', () {
        expect(SignUpState().isValid, isFalse);
      });

      test('is true when validation succeeds', () {
        expect(
          SignUpState()
              .withEmail(email)
              .withPassword(password)
              .withConfirmedPassword(password)
              .isValid,
          isTrue,
        );
      });
    });
  });
}
