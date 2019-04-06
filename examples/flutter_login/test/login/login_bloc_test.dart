import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/login/login.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

void main() {
  LoginBloc loginBloc;
  MockUserRepository userRepository;
  MockAuthenticationBloc authenticationBloc;

  setUp(() {
    userRepository = MockUserRepository();
    authenticationBloc = MockAuthenticationBloc();
    loginBloc = LoginBloc(
      userRepository: userRepository,
      authenticationBloc: authenticationBloc,
    );
  });

  test('initial state is correct', () {
    expect(LoginInitial(), loginBloc.initialState);
  });

  test('dispose does not emit new states', () {
    expectLater(
      loginBloc.state,
      emitsInOrder([LoginInitial()]),
    );
    loginBloc.dispose();
  });

  group('LoginButtonPressed', () {
    test('emits token on success', () {
      final expectedResponse = [
        LoginInitial(),
        LoginLoading(),
        LoginInitial(),
      ];

      when(userRepository.authenticate(
        username: 'valid.username',
        password: 'valid.password',
      )).thenAnswer((_) => Future.value('token'));

      expectLater(
        loginBloc.state,
        emitsInOrder(expectedResponse),
      ).then((_) {
        verify(authenticationBloc.dispatch(LoggedIn(token: 'token'))).called(1);
      });

      loginBloc.dispatch(LoginButtonPressed(
        username: 'valid.username',
        password: 'valid.password',
      ));
    });
  });
}
