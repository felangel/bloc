part of 'my_form_bloc.dart';

class MyFormState extends Equatable {
  const MyFormState({
    this.phoneField = const PhoneField.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzStatus.pure,
  });

  final PhoneField phoneField;
  final Email email;
  final Password password;
  final FormzStatus status;

  MyFormState copyWith({
    PhoneField? phoneField,
    Email? email,
    Password? password,
    FormzStatus? status,
  }) {
    return MyFormState(
      phoneField: phoneField ?? this.phoneField,
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [phoneField, email, password, status];
}
