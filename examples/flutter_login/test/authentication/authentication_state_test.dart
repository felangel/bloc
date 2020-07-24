import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// ignore: must_be_immutable
class MockUser extends Mock implements User {}

void main() {
  group('AuthenticationState', () {
    group('AuthenticationState.initial', () {
      test('supports value comparisons', () {
        expect(AuthenticationState.initial(), AuthenticationState.initial());
      });
    });

    group('AuthenticationState.authenticated', () {
      test('supports value comparisons', () {
        final user = MockUser();
        expect(
          AuthenticationState.authenticated(user),
          AuthenticationState.authenticated(user),
        );
      });
    });

    group('AuthenticationState.unauthenticated', () {
      test('supports value comparisons', () {
        expect(
          AuthenticationState.unauthenticated(),
          AuthenticationState.unauthenticated(),
        );
      });
    });
  });
}
