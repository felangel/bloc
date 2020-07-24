import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_login/login/login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mockito/mockito.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  LoginBloc loginBloc;
  MockAuthenticationRepository authenticationRepository;

  setUp(() {
    authenticationRepository = MockAuthenticationRepository();
    loginBloc = LoginBloc(authenticationRepository: authenticationRepository);
  });

  group('LoginBloc', () {
    test('throws AssertionError when authenticationRepository is null', () {
      expect(() => LoginBloc(authenticationRepository: null),
          throwsAssertionError);
    });

    test('initial state is LoginState', () {
      expect(loginBloc.state, const LoginState());
    });

    group('LoginSubmitted', () {
      blocTest(
        'emits [submissionInProgress, submissionSuccess] '
        'when login succeeds',
        build: () {
          when(authenticationRepository.logIn(
            username: 'username',
            password: 'password',
          )).thenAnswer((_) => Future.value('user'));
          return loginBloc;
        },
        act: (bloc) {
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
        build: () {
          when(authenticationRepository.logIn(
            username: 'username',
            password: 'password',
          )).thenThrow(Exception('oops'));
          return loginBloc;
        },
        act: (bloc) {
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
