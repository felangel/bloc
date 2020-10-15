import 'package:flutter_firebase_login/authentication/models/password.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';

enum ConfirmedPasswordValidationError { invalid }

class ConfirmedPassword
    extends FormzInput<String, ConfirmedPasswordValidationError> {
  const ConfirmedPassword.pure()
      : original = const Password.pure(),
        super.pure('');
  const ConfirmedPassword.dirty({@required this.original, String value = ''})
      : super.dirty(value);

  final Password original;

  @override
  ConfirmedPasswordValidationError validator(String value) {
    return original.value == value
        ? null
        : ConfirmedPasswordValidationError.invalid;
  }
}
