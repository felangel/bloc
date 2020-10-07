part of 'sign_up_cubit.dart';

class SignUpState extends Equatable {
  const SignUpState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const Password.pure(),
    this.passwordMatch = FormzStatus.pure,
    this.status = FormzStatus.pure,
  });

  final Email email;
  final Password password;
  final Password confirmPassword;
  final FormzStatus passwordMatch;
  final FormzStatus status;

  @override
  List<Object> get props => [email, password, status, confirmPassword, passwordMatch];

  SignUpState copyWith({
    Email email,
    Password password,
    Password confirmPassword,
    FormzStatus passwordMatch,
    FormzStatus status,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      passwordMatch: passwordMatch ?? this.passwordMatch,
      status: status ?? this.status,
    );
  }
}
