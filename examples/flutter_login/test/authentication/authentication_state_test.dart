import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:user_repository/user_repository.dart';

// ignore: must_be_immutable
class MockUser extends Mock implements User {}

void main() {
  group('AuthenticationState', () {
    group('AuthenticationInProgress', () {
      test('supports value comparisons', () {
        expect(AuthenticationInProgress(), AuthenticationInProgress());
      });
    });

    group('AuthenticationAuthenticated', () {
      test('supports value comparisons', () {
        final user = MockUser();
        expect(
          AuthenticationAuthenticated(user),
          AuthenticationAuthenticated(user),
        );
      });
    });

    group('AuthenticationUnauthenticated', () {
      test('supports value comparisons', () {
        expect(
          AuthenticationUnauthenticated(),
          AuthenticationUnauthenticated(),
        );
      });
    });
  });
}
