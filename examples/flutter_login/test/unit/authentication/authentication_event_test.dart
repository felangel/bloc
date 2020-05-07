import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthenticationEvent', () {
    group('AppStarted', () {
      test('props are []', () {
        expect(AuthenticationStarted().props, []);
      });

      test('toString is "AppStarted"', () {
        expect(AuthenticationStarted().toString(), 'AppStarted');
      });
    });

    group('LoggedIn', () {
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

    group('LoggedOut', () {
      test('props are []', () {
        expect(AuthenticationLoggedOut().props, []);
      });

      test('toString is "LoggedOut"', () {
        expect(AuthenticationLoggedOut().toString(), 'LoggedOut');
      });
    });
  });
}
