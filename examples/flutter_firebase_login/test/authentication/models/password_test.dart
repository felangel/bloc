// ignore_for_file: prefer_const_constructors
import 'package:flutter_firebase_login/authentication/authentication.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const passwordString = 'T0pS3cr3t123';
  group('Password', () {
    group('constructors', () {
      test('pure creates correct instance', () {
        final password = Password.pure();
        expect(password.value, '');
        expect(password.pure, true);
      });

      test('dirty creates correct instance', () {
        final password = Password.dirty(passwordString);
        expect(password.value, passwordString);
        expect(password.pure, false);
      });
    });

    group('validator', () {
      test('returns invalid error when password is empty', () {
        expect(
          Password.dirty('').error,
          PasswordValidationError.invalid,
        );
      });

      test('is valid when password is not empty', () {
        expect(
          Password.dirty(passwordString).error,
          isNull,
        );
      });
    });
  });
}
