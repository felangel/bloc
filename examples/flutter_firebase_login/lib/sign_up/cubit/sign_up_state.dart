part of 'sign_up_cubit.dart';

final class SignUpState extends Equatable {
  const SignUpState._({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  const SignUpState.initial() : this._();

  final Email email;
  final Password password;
  final ConfirmedPassword confirmedPassword;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  SignUpState dirtyEmail(String email) {
    return SignUpState._(
      email: Email.dirty(email),
      password: password,
      confirmedPassword: confirmedPassword,
    );
  }

  SignUpState dirtyPassword(String password) {
    return SignUpState._(
      email: email,
      password: Password.dirty(password),
      confirmedPassword: confirmedPassword,
    );
  }

  SignUpState dirtyConfirmedPassword(String confirmedPassword) {
    return SignUpState._(
      email: email,
      password: password,
      confirmedPassword: ConfirmedPassword.dirty(
        password: password.value,
        value: confirmedPassword,
      ),
    );
  }

  SignUpState submissionInProgress() {
    return SignUpState._(
      email: email,
      password: password,
      confirmedPassword: confirmedPassword,
      status: FormzSubmissionStatus.inProgress,
    );
  }

  SignUpState submissionSuccess() {
    return SignUpState._(
      email: email,
      password: password,
      confirmedPassword: confirmedPassword,
      status: FormzSubmissionStatus.success,
    );
  }

  SignUpState submissionFailure([String? error]) {
    return SignUpState._(
      email: email,
      password: password,
      confirmedPassword: confirmedPassword,
      status: FormzSubmissionStatus.failure,
      errorMessage: error,
    );
  }

  bool get isValid => Formz.validate([email, password, confirmedPassword]);

  @override
  List<Object?> get props => [
        email,
        password,
        confirmedPassword,
        status,
        errorMessage,
      ];
}
