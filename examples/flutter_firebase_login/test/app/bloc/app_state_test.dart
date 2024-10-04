// ignore_for_file: prefer_const_constructors
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_firebase_login/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {}

void main() {
  group(AppState, () {
    test(
        'returns state with status unauthenticated '
        'when user is empty', () {
      expect(AppState().status, equals(AppStatus.unauthenticated));
    });

    test(
        'returns state with status authenticated and user '
        'when user is not empty', () {
      final user = MockUser();
      final state = AppState(user: user);
      expect(state.status, equals(AppStatus.authenticated));
      expect(state.user, equals(user));
    });
  });
}
