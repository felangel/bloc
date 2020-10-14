import 'package:equatable/equatable.dart';

enum AuthStatus { success, failed, login }

abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class EmailChange extends LoginEvent {
  final String email;

  EmailChange(this.email);
}

class PasswordChange extends LoginEvent {
  final String password;

  PasswordChange(this.password);
}

class ButtonActive extends LoginEvent {
  final bool isActive;
  ButtonActive(this.isActive);
}

class SubmitLogin extends LoginEvent {
  final String email;
  final String password;

  SubmitLogin(this.email, this.password);
}
