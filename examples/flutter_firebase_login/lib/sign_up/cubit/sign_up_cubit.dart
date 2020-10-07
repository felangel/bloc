import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_firebase_login/authentication/authentication.dart';
import 'package:formz/formz.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._authenticationRepository)
      : assert(_authenticationRepository != null),
        super(const SignUpState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([email, state.password, state.confirmPassword]),
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    final passwordMatch = (password == state.confirmPassword) ? FormzStatus.valid : FormzStatus.invalid;
    final status = (Formz.validate([state.email, password, state.confirmPassword]).isValid && passwordMatch.isValid) ? FormzStatus.valid : FormzStatus.invalid;
    emit(state.copyWith(
      password: password,
      passwordMatch: passwordMatch,
      status: status,
    ));
  }

  void confirmPasswordChanged(String value) {
    final confirmPassword = Password.dirty(value);
    final passwordMatch = (state.password == confirmPassword) ? FormzStatus.valid : FormzStatus.invalid;
    final status = (Formz.validate([state.email, state.password, confirmPassword]).isValid && passwordMatch.isValid) ? FormzStatus.valid : FormzStatus.invalid;
    emit(state.copyWith(
      confirmPassword: confirmPassword,
      passwordMatch: passwordMatch,
      status: status,
    ));
  }

  Future<void> signUpFormSubmitted() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
      );
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on Exception {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}
