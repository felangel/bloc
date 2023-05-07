part of 'my_form_bloc.dart';

final class MyFormState extends Equatable {
  const MyFormState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
    this.status = FormzSubmissionStatus.initial,
  });

  final Email email;
  final Password password;
  final bool isValid;
  final FormzSubmissionStatus status;

  MyFormState copyWith({
    Email? email,
    Password? password,
    bool? isValid,
    FormzSubmissionStatus? status,
  }) {
    return MyFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [email, password, status];
}
