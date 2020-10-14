import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;
  final String uuid;

  AuthLogin(this.email, this.password, this.uuid);

  @override
  List<Object> get props => [email, password, uuid];
}
