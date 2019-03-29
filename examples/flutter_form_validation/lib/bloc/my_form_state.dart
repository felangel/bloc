import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class MyFormState extends Equatable {
  final String email;
  final bool isEmailValid;
  final String password;
  final bool isPasswordValid;
  final bool formSubmittedSuccessfully;

  bool get isFormValid => isEmailValid && isPasswordValid;

  MyFormState({
    @required this.email,
    @required this.isEmailValid,
    @required this.password,
    @required this.isPasswordValid,
    @required this.formSubmittedSuccessfully,
  }) : super([
          email,
          isEmailValid,
          password,
          isPasswordValid,
          formSubmittedSuccessfully,
        ]);

  factory MyFormState.initial() {
    return MyFormState(
      email: '',
      isEmailValid: false,
      password: '',
      isPasswordValid: false,
      formSubmittedSuccessfully: false,
    );
  }

  MyFormState copyWith({
    String email,
    bool isEmailValid,
    String password,
    bool isPasswordValid,
    bool formSubmittedSuccessfully,
  }) {
    return MyFormState(
      email: email ?? this.email,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      password: password ?? this.password,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      formSubmittedSuccessfully:
          formSubmittedSuccessfully ?? this.formSubmittedSuccessfully,
    );
  }

  @override
  String toString() {
    return '''MyFormState {
      email: $email,
      isEmailValid: $isEmailValid,
      password: $password,
      isPasswordValid: $isPasswordValid,
      formSubmittedSuccessfully: $formSubmittedSuccessfully
    }''';
  }
}
