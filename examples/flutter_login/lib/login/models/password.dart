import 'package:formz/formz.dart';

enum PasswordValidationError { empty }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : PasswordValidationError.empty;
  }
}

extension PasswordValidationErrorExtension on PasswordValidationError {
  String text() {
    switch (this) {
      case PasswordValidationError.empty:
        return 'Password is required';
    }
  }
}
