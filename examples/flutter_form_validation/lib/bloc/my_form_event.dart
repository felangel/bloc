part of 'my_form_bloc.dart';

abstract class MyFormEvent extends Equatable {
  const MyFormEvent();

  @override
  List<Object> get props => [];
}

class EmailChanged extends MyFormEvent {
  const EmailChanged({@required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

class PasswordChanged extends MyFormEvent {
  const PasswordChanged({@required this.password});

  final String password;

  @override
  List<Object> get props => [password];
}

class FormSubmitted extends MyFormEvent {}
