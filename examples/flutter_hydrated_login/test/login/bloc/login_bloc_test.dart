import 'package:flutter_hydrated_login/bloc/login/bloc.dart';
import 'package:flutter_hydrated_login/bloc/login/login_bloc.dart';
import 'package:flutter_hydrated_login/models/user.dart';
import 'package:flutter_hydrated_login/repositorys/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';

class AuthMock extends Mock implements AuthRepository {}

main() {
  LoginBloc loginBloc;
  AuthMock authMockRepository;

  User userMock;

  setUp(() {
    authMockRepository = AuthMock();
    loginBloc = LoginBloc(authMockRepository);
    userMock = User(
        email: 'loremipsum@gmail.com', password: 'Sayursop123', uuid: '123');
  });

  tearDown(() {
    loginBloc?.close();
  });

  test('Initstate', () {
    expect(loginBloc.state, MyFormChange());
  });

  group('Email Form', () {
    blocTest<LoginBloc, LoginState>(
        'emit [null] email format match',
        build: () => loginBloc,
        act: (bloc) => bloc.add(EmailChange('loremipsum@gmail.com')),
        expect: [
          MyFormChange(email: 'loremipsum@gmail.com'),
        ],
        verify: (value) {
          final currentState = value.state as MyFormChange;
          expect(currentState.emailValidation(), isNull);
        });

    blocTest<LoginBloc, LoginState>(
        'emit [null] error message at textfield email',
        build: () => loginBloc,
        act: (bloc) => bloc.add(EmailChange('loremipsum')),
        expect: <LoginState>[MyFormChange(email: 'loremipsum')],
        verify: (value) {
          final currentstate = value.state as MyFormChange;
          expect(currentstate.emailValidation(), isNotEmpty);
        });
  });

  group('Password Form', () {
    blocTest<LoginBloc, LoginState>(
        'emit [null] password format match',
        build: () => loginBloc,
        act: (bloc) => bloc.add(PasswordChange('Sayursop123')),
        expect: <LoginState>[MyFormChange(password: 'Sayursop123')],
        verify: (value) {
          final currentstate = value.state as MyFormChange;
          expect(currentstate.passwordValidation(), isNull);
        });

    blocTest<LoginBloc, LoginState>(
        'emit [string] error message password validation',
        build: () => loginBloc,
        act: (bloc) => bloc.add(PasswordChange('Sayursop')),
        expect: <LoginState>[MyFormChange(password: 'Sayursop')],
        verify: (value) {
          final currentstate = value.state as MyFormChange;
          expect(currentstate.passwordValidation(), isNotEmpty);
        });
  });

  group('Submit Login', () {
    blocTest<LoginBloc, LoginState>(
        'emit [email, password, submitLogin] active button login',
        build: () => loginBloc,
        act: (bloc) => bloc..add(ButtonActive(false))..add(ButtonActive(true)),
        expect: <LoginState>[
          MyFormChange(isActive: false),
          MyFormChange(isActive: true),
        ]);

    blocTest<LoginBloc, LoginState>(
        'emit [false, user] submited login button',
        build: () {
          when(authMockRepository.fetchUser('lorem@gmail.com', '123'))
              .thenAnswer((value) async {
            return userMock;
          });
          return loginBloc;
        },
        act: (bloc) =>
            bloc.add(SubmitLogin('loremipsum@gmail.com', 'Sayursop123')),
        expect: <LoginState>[
          MyFormChange(isActive: false),
          MyFormChange(userState: UserState(user: userMock)),
        ]);
  });
}
