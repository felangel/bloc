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
  group(AppBloc, () {
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
      when(() => user.isNotEmpty).thenReturn(false);
    });

    AppBloc buildBloc() {
      return AppBloc(
        authenticationRepository: authenticationRepository,
      );
    }

    test('initial state is $AppState.fromUser', () {
      expect(
        buildBloc().state,
        AppState.fromUser(user),
      );
    });

    group(AppUserSubscriptionRequested, () {
      final error = Exception('oops');

      blocTest<AppBloc, AppState>(
        'emits $AppState.fromUser when user stream emits a new value',
        setUp: () {
          when(() => user.isNotEmpty).thenReturn(true);
          when(() => authenticationRepository.user).thenAnswer(
            (_) => Stream.value(user),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AppUserSubscriptionRequested()),
        expect: () => [AppState.fromUser(user)],
      );

      blocTest<AppBloc, AppState>(
        'adds error when user stream emits an error',
        setUp: () {
          when(
            () => authenticationRepository.user,
          ).thenAnswer((_) => Stream.error(error));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AppUserSubscriptionRequested()),
        errors: () => [error],
      );
    });

    group(AppLogoutPressed, () {
      blocTest<AppBloc, AppState>(
        'invokes logOut',
        setUp: () {
          when(
            () => authenticationRepository.logOut(),
          ).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(AppLogoutPressed()),
        verify: (_) {
          verify(() => authenticationRepository.logOut()).called(1);
        },
      );
    });
  });
}
