import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_login/login/bloc/login_bloc.dart';

void main() {
  group('LoginState', () {
    group('LoginInitial', () {
      test('props are []', () {
        expect(LoginInitial().props, []);
      });

      test('toString is LoginInitial', () {
        expect(LoginInitial().toString(), 'LoginInitial');
      });
    });

    group('LoginInProgress', () {
      test('props are []', () {
        expect(LoginInProgress().props, []);
      });

      test('toString is LoginLoading', () {
        expect(LoginInProgress().toString(), 'LoginInProgress');
      });
    });

    group('LoginFailure', () {
      test('props are [error]', () {
        expect(LoginFailure(error: 'error').props, ['error']);
      });

      test('toString is LoginFailure { error: error }', () {
        expect(
          LoginFailure(error: 'error').toString(),
          'LoginFailure { error: error }',
        );
      });
    });
  });
}
