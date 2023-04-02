import 'package:formz/formz.dart';

enum PhoneFieldError { invalid }

class PhoneField extends FormzInput<String, PhoneFieldError> {
  const PhoneField.pure([super.value = '']) : super.pure();
  const PhoneField.dirty([super.value = '']) : super.dirty();

  static final _phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
  @override
  PhoneFieldError? validator(String? value) {
    return _phoneRegex.hasMatch(value ?? '') ? null : PhoneFieldError.invalid;
  }
}
