import 'dart:async';

import 'package:flutter_login/profile/bloc/profile_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:user_repository/user_repository.dart';

class MockProfileStorage extends Mock implements HydratedStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  HydratedStorage _storage;

  ProfileBloc bloc;

  setUp(() async {
    _storage = MockProfileStorage();
    HydratedBloc.storage = _storage;
    bloc = ProfileBloc();
    when(_storage.write(any, any)).thenAnswer((_) async {});
  });

  tearDown(() {
    bloc?.close();
  });

  group('Profile Bloc', () {
    final user = const User('123');

    test('initstatte', () {
      expect(bloc.state, isA<ProfileEmpty>());
    });

    test('read profile_bloc storage', () async {
      when<dynamic>(_storage.read('ProfileBloc')).thenReturn(
        {'user': user},
      );
      expect(bloc.state, isA<ProfileEmpty>());

      bloc.add(ProfileStore(user));

      await expectLater(bloc, emitsInOrder([ProfileUser(user)]));
    });

    test('profile_bloc error', () {
      runZoned(() async {
        when<dynamic>(_storage.read('ProfileBloc')).thenThrow('oops');
        bloc.add(ProfileStore(user));
      }).catchError((e) {
        expect(bloc.state, isA<ProfileError>());
        bloc.close();
      });
    });
  });
}
