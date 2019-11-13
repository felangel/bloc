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

  tearDown(() {
    loginBloc?.close();
    authenticationBloc?.close();
  });

  test('initial state is correct', () {
    expect(LoginInitial(), loginBloc.initialState);
  });

  test('close does not emit new states', () {
    expectLater(
      loginBloc,
      emitsInOrder([LoginInitial(), emitsDone]),
    );
    loginBloc.close();
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
        loginBloc,
        emitsInOrder(expectedResponse),
      ).then((_) {
        verify(authenticationBloc.add(LoggedIn(token: 'token'))).called(1);
      });

      loginBloc.add(LoginButtonPressed(
        username: 'valid.username',
        password: 'valid.password',
      ));
    });
  });
}
