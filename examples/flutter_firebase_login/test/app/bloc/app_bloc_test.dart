// ignore_for_file: prefer_const_constructors, must_be_immutable
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_firebase_login/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockUser extends Mock implements User {}

void main() {
  group('AppBloc', () {
    final user = MockUser();
    late AuthenticationRepository authenticationRepository;

    setUp(() {
      authenticationRepository = MockAuthenticationRepository();
      when(() => authenticationRepository.user).thenAnswer(
        (_) => Stream.empty(),
      );
      when(
        () => authenticationRepository.currentUser,
      ).thenReturn(User.empty);
    });

    test('initial state is unauthenticated when user is empty', () {
      expect(
        AppBloc(authenticationRepository: authenticationRepository).state,
        AppState.unauthenticated(),
      );
    });

    group('UserChanged', () {
      blocTest<AppBloc, AppState>(
        'emits authenticated when user is not empty',
        setUp: () {
          when(() => user.isNotEmpty).thenReturn(true);
          when(() => authenticationRepository.user).thenAnswer(
            (_) => Stream.value(user),
          );
        },
        build: () => AppBloc(
          authenticationRepository: authenticationRepository,
        ),
        seed: AppState.unauthenticated,
        expect: () => [AppState.authenticated(user)],
      );

      blocTest<AppBloc, AppState>(
        'emits unauthenticated when user is empty',
        setUp: () {
          when(() => authenticationRepository.user).thenAnswer(
            (_) => Stream.value(User.empty),
          );
        },
        build: () => AppBloc(
          authenticationRepository: authenticationRepository,
        ),
        expect: () => [AppState.unauthenticated()],
      );
    });

    group('LogoutRequested', () {
      blocTest<AppBloc, AppState>(
        'invokes logOut',
        setUp: () {
          when(
            () => authenticationRepository.logOut(),
          ).thenAnswer((_) async {});
        },
        build: () => AppBloc(
          authenticationRepository: authenticationRepository,
        ),
        act: (bloc) => bloc.add(AppLogoutRequested()),
        verify: (_) {
          verify(() => authenticationRepository.logOut()).called(1);
        },
      );
    });
  });
}
