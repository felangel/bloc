part of 'login_bloc.dart';

class LoginState extends Equatable with FormzMixin {
  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
  });

  final FormzSubmissionStatus status;
  final Username username;
  final Password password;

  LoginState copyWith({
    FormzSubmissionStatus? status,
    Username? username,
    Password? password,
  }) {
    return LoginState(
      status: status ?? this.status,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  List<Object> get props => [status, username, password];
  
  @override
  List<FormzInput> get inputs => [username, password];

  
}
