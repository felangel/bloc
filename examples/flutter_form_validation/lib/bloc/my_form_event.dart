import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MyFormEvent extends Equatable {
  MyFormEvent([List props = const []]) : super(props);
}

class EmailChanged extends MyFormEvent {
  final String email;

  EmailChanged({@required this.email}) : super([email]);

  @override
  String toString() => 'EmailChanged { email: $email }';
}

class PasswordChanged extends MyFormEvent {
  final String password;

  PasswordChanged({@required this.password}) : super([password]);

  @override
  String toString() => 'PasswordChanged { password: $password }';
}

class FormSubmitted extends MyFormEvent {
  @override
  String toString() => 'FormSubmitted';
}

class FormReset extends MyFormEvent {
  @override
  String toString() => 'FormReset';
}
