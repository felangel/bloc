import 'dart:async';

import 'package:flutter_hydrated_login/bloc/auth/bloc.dart';
import 'package:flutter_hydrated_login/bloc/login/login_event.dart';
import 'package:flutter_hydrated_login/models/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mockito/mockito.dart';

class MockHydrated extends Mock implements HydratedStorage {}

main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AuthBloc _bloc;
  HydratedStorage _storage;

  setUp(() async {
    _storage = MockHydrated();
    HydratedBloc.storage = _storage;
    _bloc = AuthBloc();
    when(_storage.write(any, any)).thenAnswer((_) async {});
  });

  tearDown(() {
    _bloc?.close();
  });

  test('init state', () {
    expect(_bloc.state, isA<AuthEmpty>());
  });

  group('bloc', () {
    final user = User(
        email: 'loremipsum@gmail.com', password: '123123', uuid: '0987-09083');

    test('init state', () {
      verify<dynamic>(_storage.read('AuthBloc')).called(1);
    });

    test('reads from storage', () async {
      when<dynamic>(_storage.read('AuthBloc')).thenReturn(
        User.toMap(user),
      );
      final newBloc = AuthBloc();
      expect((newBloc.state as AuthUser).user, user);
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache is empty', () async {
      when(_storage.read('AuthBloc')).thenReturn(null);

      final bloc = AuthBloc();

      expect(bloc.state, AuthEmpty());

      bloc.add(AuthLogin(user.email, user.password, user.uuid));

      await expectLater(bloc, emitsInOrder([AuthUser(user)]));

      verify<dynamic>(_storage.read('AuthBloc')).called(2);
    });

    test(
        'does not read from storage on subsequent state change'
        'when cache malformed', () {
      runZoned(() async {
        when(_storage.read('AuthBloc')).thenReturn('{');

        final bloc = AuthBloc();

        bloc.add(AuthLogin(user.email, user.password, user.uuid));
      }).catchError((e) {
        verify<dynamic>(_storage.read('AuthBloc')).called(2);
      });
    });
  });
}
