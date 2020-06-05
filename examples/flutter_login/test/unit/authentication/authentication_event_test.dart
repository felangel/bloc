import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthenticationEvent', () {
    group('AuthenticationStarted', () {
      test('props are []', () {
        expect(AuthenticationStarted().props, []);
      });

      test('toString is "AuthenticationStarted"', () {
        expect(AuthenticationStarted().toString(), 'AuthenticationStarted');
      });
    });

    group('AuthenticationLoggedIn', () {
      test('props are [token]', () {
        expect(AuthenticationLoggedIn(token: 'token').props, ['token']);
      });

      test('toString is "LoggedIn { token: token }"', () {
        expect(
          AuthenticationLoggedIn(token: 'token').toString(),
          'LoggedIn { token: token }',
        );
      });
    });

    group('AuthenticationLoggedOut', () {
      test('props are []', () {
        expect(AuthenticationLoggedOut().props, []);
      });

      test('toString is "AuthenticationLoggedOut"', () {
        expect(AuthenticationLoggedOut().toString(), 'AuthenticationLoggedOut');
      });
    });
  });
}
