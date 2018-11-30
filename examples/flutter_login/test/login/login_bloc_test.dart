import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_login/login/login.dart';

void main() {
  LoginBloc loginBloc;

  setUp(() {
    loginBloc = LoginBloc();
  });

  test('initial state is correct', () {
    expect(LoginState.initial(), loginBloc.initialState);
  });

  test('dispose does not emit new states', () {
    expectLater(
      loginBloc.state,
      emitsInOrder([]),
    );
    loginBloc.dispose();
  });

  group('LoginButtonPressed', () {
    test('emits token on success', () {
      final expectedResponse = [
        LoginState.loading(),
        LoginState.success('token'),
      ];

      expectLater(
        loginBloc.state,
        emitsInOrder(expectedResponse),
      );

      loginBloc.dispatch(LoginButtonPressed(
        username: 'valid.username',
        password: 'valid.password',
      ));
    });
  });
}
