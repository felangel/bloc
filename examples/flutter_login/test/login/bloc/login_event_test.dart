// ignore_for_file: prefer_const_constructors
import 'package:flutter_login/login/login.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const username = 'mock-username';
  const password = 'mock-password';
  group('LoginEvent', () {
    group('LoginUsernameChanged', () {
      test('supports value comparisons', () {
        expect(LoginUsernameChanged(username), LoginUsernameChanged(username));
      });
    });

    group('LoginPasswordChanged', () {
      test('supports value comparisons', () {
        expect(LoginPasswordChanged(password), LoginPasswordChanged(password));
      });
    });

    group('LoginSubmitted', () {
      test('supports value comparisons', () {
        expect(LoginSubmitted(), LoginSubmitted());
      });
    });
  });
}
