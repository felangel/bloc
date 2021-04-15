// ignore_for_file: prefer_const_constructors
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    const id = 'mock-id';
    const email = 'mock-email';

    test('uses value equality', () {
      expect(
        User(email: email, id: id, name: null, photo: null),
        User(email: email, id: id, name: null, photo: null),
      );
    });

    test('isAnonymous returns true for anonymous user', () {
      expect(User.anonymous.isAnonymous, isTrue);
    });

    test('isAnonymous returns false for non-anonymous user', () {
      final user = User(email: email, id: id, name: null, photo: null);
      expect(user.isAnonymous, isFalse);
    });

    test('isNotAnonymous returns false for anonymous user', () {
      expect(User.anonymous.isNotAnonymous, isFalse);
    });

    test('isNotAnonymous returns true for non-anonymous user', () {
      final user = User(email: email, id: id, name: null, photo: null);
      expect(user.isNotAnonymous, isTrue);
    });
  });
}
