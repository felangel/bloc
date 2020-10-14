import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hydrated_login/repositorys/auth_repository.dart';

import 'bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  AuthRepository _repository;

  LoginBloc(AuthRepository repository) : super(MyFormChange()) {
    this._repository = repository;
  }

  @override
  Stream<Transition<LoginEvent, LoginState>> transformEvents(
      Stream<LoginEvent> events, transitionFn) {
    return super.transformEvents(events, transitionFn);
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    final currentState = state;
    try {
      switch (event.runtimeType) {
        case EmailChange:
          final eventEmail = event as EmailChange;
          if (currentState is MyFormChange) {
            yield currentState.copyWith(emailNew: eventEmail.email);
          }
          break;
        case PasswordChange:
          final eventPassword = event as PasswordChange;
          if (currentState is MyFormChange) {
            yield currentState.copyWith(passNew: eventPassword.password);
          }
          break;
        case ButtonActive:
          final activeButton = event as ButtonActive;
          if (currentState is MyFormChange) {
            yield currentState.copyWith(isNewActivate: activeButton.isActive);
          }
          break;
        case SubmitLogin:
          if (currentState is MyFormChange) {
            yield currentState.copyWith(isNewActivate: false);

            // assumse this is response from server
            final resultFetch = await _repository.fetchUser(
                currentState.email, currentState.password);

            final userData = UserState(user: resultFetch);

            yield currentState.copyWith(user: userData);
          }
          break;
        default:
          throw ArgumentError();
      }
    } catch (e) {
      yield LoginError('something wrong');
    }
  }
}
