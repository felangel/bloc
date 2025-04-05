part of 'login_cubit.dart';

final class LoginState extends Equatable {
  const LoginState._({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  const LoginState.initial() : this._();

  LoginState dirtyEmail(String email) {
    return LoginState._(
      email: Email.dirty(email),
      password: password,
    );
  }

  LoginState dirtyPassword(String password) {
    return LoginState._(
      email: email,
      password: Password.dirty(password),
    );
  }

  LoginState submissionInProgress() {
    return LoginState._(
      email: email,
      password: password,
      status: FormzSubmissionStatus.inProgress,
    );
  }

  LoginState submissionSuccess() {
    return LoginState._(
      email: email,
      password: password,
      status: FormzSubmissionStatus.success,
    );
  }

  LoginState submissionFailure([String? error]) {
    return LoginState._(
      email: email,
      password: password,
      status: FormzSubmissionStatus.failure,
      errorMessage: error,
    );
  }

  final Email email;
  final Password password;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  bool get isValid => Formz.validate([email, password]);

  @override
  List<Object?> get props => [email, password, status, errorMessage];
}
