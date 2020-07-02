import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_form_validation/models/models.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';

part 'my_form_event.dart';
part 'my_form_state.dart';

class MyFormBloc extends Bloc<MyFormEvent, MyFormState> {
  MyFormBloc() : super(const MyFormState());

  @override
  void onTransition(Transition<MyFormEvent, MyFormState> transition) {
    print(transition);
    super.onTransition(transition);
  }

  @override
  Stream<MyFormState> mapEventToState(
    MyFormEvent event,
  ) async* {
    if (event is EmailChanged) {
      final email = Email.dirty(event.email);
      yield state.copyWith(
        email: email,
        status: Formz.validate([email, state.password]),
      );
    } else if (event is PasswordChanged) {
      final password = Password.dirty(event.password);
      yield state.copyWith(
        password: password,
        status: Formz.validate([state.email, password]),
      );
    } else if (event is FormSubmitted) {
      if (state.status.isValidated) {
        yield state.copyWith(status: FormzStatus.submissionInProgress);
        await Future.delayed(const Duration(seconds: 1));
        yield state.copyWith(status: FormzStatus.submissionSuccess);
      }
    }
  }
}
