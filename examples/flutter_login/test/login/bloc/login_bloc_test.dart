import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:formz/formz.dart';
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

  group('LoginBloc', () {
    test('throws AssertionError when userRepository is null', () {
      expect(() => LoginBloc(userRepository: null), throwsAssertionError);
    });

    test('initial state is LoginState', () {
      expect(loginBloc.state, const LoginState());
    });

    group('LoginSubmitted', () {
      blocTest(
        'emits [submissionInProgress, submissionSuccess] '
        'when login succeeds',
        build: () async {
          when(userRepository.logIn(
            username: 'username',
            password: 'password',
          )).thenAnswer((_) => Future.value('user'));
          return loginBloc;
        },
        act: (bloc) async {
          bloc
            ..add(const LoginUsernameChanged('username'))
            ..add(const LoginPasswordChanged('password'))
            ..add(const LoginSubmitted());
        },
        expect: [
          const LoginState(
            username: Username.dirty('username'),
            status: FormzStatus.invalid,
          ),
          const LoginState(
            username: Username.dirty('username'),
            password: Password.dirty('password'),
            status: FormzStatus.valid,
          ),
          const LoginState(
            username: Username.dirty('username'),
            password: Password.dirty('password'),
            status: FormzStatus.submissionInProgress,
          ),
          const LoginState(
            username: Username.dirty('username'),
            password: Password.dirty('password'),
            status: FormzStatus.submissionSuccess,
          ),
        ],
      );

      blocTest(
        'emits [LoginInProgress, LoginFailure] when logIn fails',
        build: () async {
          when(userRepository.logIn(
            username: 'username',
            password: 'password',
          )).thenThrow(Exception('oops'));
          return loginBloc;
        },
        act: (bloc) async {
          bloc
            ..add(const LoginUsernameChanged('username'))
            ..add(const LoginPasswordChanged('password'))
            ..add(const LoginSubmitted());
        },
        expect: [
          const LoginState(
            username: Username.dirty('username'),
            status: FormzStatus.invalid,
          ),
          const LoginState(
            username: Username.dirty('username'),
            password: Password.dirty('password'),
            status: FormzStatus.valid,
          ),
          const LoginState(
            username: Username.dirty('username'),
            password: Password.dirty('password'),
            status: FormzStatus.submissionInProgress,
          ),
          const LoginState(
            username: Username.dirty('username'),
            password: Password.dirty('password'),
            status: FormzStatus.submissionFailure,
          ),
        ],
      );
    });
  });
}
