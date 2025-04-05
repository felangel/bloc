import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._authenticationRepository) : super(const SignUpState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String email) => emit(state.withEmail(email));

  void passwordChanged(String password) => emit(state.withPassword(password));

  void confirmedPasswordChanged(String confirmedPassword) {
    emit(state.withConfirmedPassword(confirmedPassword));
  }

  Future<void> signUpFormSubmitted() async {
    if (!state.isValid) return;
    emit(state.withSubmissionInProgress());
    try {
      await _authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
      );
      emit(state.withSubmissionSuccess());
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      emit(state.withSubmissionFailure(e.message));
    } catch (_) {
      emit(state.withSubmissionFailure());
    }
  }
}
