import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._authenticationRepository)
      : super(const SignUpState.initial());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String email) => emit(state.dirtyEmail(email));

  void passwordChanged(String password) => emit(state.dirtyPassword(password));

  void confirmedPasswordChanged(String confirmedPassword) {
    emit(state.dirtyConfirmedPassword(confirmedPassword));
  }

  Future<void> signUpFormSubmitted() async {
    if (!state.isValid) return;
    emit(state.submissionInProgress());
    try {
      await _authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
      );
      emit(state.submissionSuccess());
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      emit(state.submissionFailure(e.message));
    } catch (_) {
      emit(state.submissionFailure());
    }
  }
}
