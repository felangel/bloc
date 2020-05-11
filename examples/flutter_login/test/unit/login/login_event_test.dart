import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_login/login/bloc/login_bloc.dart';

void main() {
  group('LoginEvent', () {
    group('LoginButtonPressed', () {
      test('props are [username, password]', () {
        expect(
          LoginButtonPressed(username: 'username', password: 'password').props,
          ['username', 'password'],
        );
      });

      test(
          //removed 'toString' as it would fail command:
          // flutter format --set-exit-if-changed test
          //line length exceeded 80 characters
          'is LoginButtonPressed { username: username, password: password }',
          () {
        expect(
          LoginButtonPressed(
            username: 'username',
            password: 'password',
          ).toString(),
          'LoginButtonPressed { username: username, password: password }',
        );
      });
    });
  });
}
