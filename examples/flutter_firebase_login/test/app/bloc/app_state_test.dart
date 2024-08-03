// ignore_for_file: prefer_const_constructors
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_firebase_login/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {}

void main() {
  group('AppState', () {
    group('fromUser', () {
      test(
          'returns state with status [unauthenticated] '
          'when user is empty', () {
        expect(
          AppState.fromUser(User.empty),
          AppState(status: AppStatus.unauthenticated),
        );
      });

      test(
          'returns state with status [authenticated] and user '
          'when user is not empty', () {
        final user = MockUser();
        when(() => user.isNotEmpty).thenReturn(true);
        expect(
          AppState.fromUser(user),
          AppState(status: AppStatus.authenticated, user: user),
        );
      });
    });
  });
}
