import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/login/login.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  LoginBloc loginBloc;
  MockUserRepository userRepository;

  setUp(() {
    userRepository = MockUserRepository();
    loginBloc = LoginBloc(userRepository: userRepository);
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
        LoginState.initial(),
        LoginState.loading(),
        LoginState.success('token'),
      ];

      when(userRepository.authenticate(
        username: 'valid.username',
        password: 'valid.password',
      )).thenAnswer((_) => Future.value('token'));

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
