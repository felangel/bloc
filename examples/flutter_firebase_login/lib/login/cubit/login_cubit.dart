import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository)
      : super(const LoginState.initial());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String email) => emit(state.dirtyEmail(email));

  void passwordChanged(String password) => emit(state.dirtyPassword(password));

  Future<void> logInWithCredentials() async {
    if (!state.isValid) return;
    emit(state.submissionInProgress());
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
      );
      emit(state.submissionSuccess());
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(state.submissionFailure(e.message));
    } catch (_) {
      emit(state.submissionFailure());
    }
  }

  Future<void> logInWithGoogle() async {
    emit(state.submissionInProgress());
    try {
      await _authenticationRepository.logInWithGoogle();
      emit(state.submissionSuccess());
    } on LogInWithGoogleFailure catch (e) {
      emit(state.submissionFailure(e.message));
    } catch (_) {
      emit(state.submissionFailure());
    }
  }
}
