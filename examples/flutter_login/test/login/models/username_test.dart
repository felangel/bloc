// ignore_for_file: prefer_const_constructors
import 'package:flutter_login/login/login.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const usernameString = 'mock-username';
  group('Username', () {
    group('constructors', () {
      test('pure creates correct instance', () {
        final username = Username.pure();
        expect(username.value, '');
        expect(username.pure, true);
      });

      test('dirty creates correct instance', () {
        final username = Username.dirty(usernameString);
        expect(username.value, usernameString);
        expect(username.pure, false);
      });
    });

    group('validator', () {
      test('returns empty error when username is empty', () {
        expect(
          Username.dirty().error,
          UsernameValidationError.empty,
        );
      });

      test('is valid when username is not empty', () {
        expect(
          Username.dirty(usernameString).error,
          isNull,
        );
      });
    });
  });
}
