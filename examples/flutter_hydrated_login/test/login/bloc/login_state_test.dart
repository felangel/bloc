import 'package:flutter_hydrated_login/bloc/login/bloc.dart';
import 'package:flutter_hydrated_login/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  MyFormChange formState;

  setUp(() {
    formState = MyFormChange(
        email: 'loremipsum@gmail.com',
        isActive: false,
        password: '123',
        userState: UserState());
  });

  group('MyFormChange', () {
    test('prop [email]', () {
      expect(formState.props[0], "loremipsum@gmail.com");
    });

    test('prop [password]', () {
      expect(formState.props[1], isA<String>());
    });

    test('prop [userState]', () {
      expect(formState.props[2], isA<UserState>());
    });

    test('prop [isActive]', () {
      expect(formState.props[3], isA<bool>());
    });

    test('copywith [email]', () {
      expect(formState.copyWith(emailNew: 'jakarta@gmail.com').email,
          'jakarta@gmail.com');
    });

    test('copywith [password]', () {
      expect(formState.copyWith(passNew: '123').password, '123');
    });

    test('copywith [isactive]', () {
      expect(formState.copyWith(isNewActivate: true).isActive, true);
    });

    test('copywith [userstate]', () {
      expect(
          formState
              .copyWith(user: UserState(user: User(email: 'lorem@dusk.com')))
              .userState
              .user
              .email,
          'lorem@dusk.com');
    });
  });
}
