import 'package:formz/formz.dart';

enum UsernameValidationError { empty }

class Username extends FormzInput<String, UsernameValidationError> {
  const Username.pure() : super.pure('');
  const Username.dirty([super.value = '']) : super.dirty();

  @override
  UsernameValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : UsernameValidationError.empty;
  }
}

extension UsernameValidationErrorExtension on UsernameValidationError {
  String text() {
    switch (this) {
      case UsernameValidationError.empty:
        return 'Username is required';
    }
  }
}
