// ignore_for_file: prefer_const_constructors
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    const id = 'mock-id';
    const email = 'mock-email';
    test('throws AssertionError when email is null', () {
      expect(
        () => User(email: null, id: id, name: null, photo: null),
        throwsAssertionError,
      );
    });

    test('throws AssertionError when id is null', () {
      expect(
        () => User(email: email, id: null, name: null, photo: null),
        throwsAssertionError,
      );
    });

    test('uses value equality', () {
      expect(
        User(email: email, id: id, name: null, photo: null),
        User(email: email, id: id, name: null, photo: null),
      );
    });
  });
}
