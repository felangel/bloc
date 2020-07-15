import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:user_repository/user_repository.dart';

// ignore: must_be_immutable
class MockUser extends Mock implements User {}

void main() {
  group('AuthenticationEvent', () {
    group('LoggedOut', () {
      test('supports value comparisons', () {
        expect(LoggedOut(), LoggedOut());
      });
    });

    group('UserChanged', () {
      test('supports value comparisons', () {
        final user = MockUser();
        expect(
          UserChanged(user),
          UserChanged(user),
        );
      });
    });
  });
}
