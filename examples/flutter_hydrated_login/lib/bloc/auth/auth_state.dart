import 'package:equatable/equatable.dart';
import 'package:flutter_hydrated_login/bloc/auth/bloc.dart';
import 'package:flutter_hydrated_login/models/user.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}



class AuthEmpty extends AuthState {}

class AuthUser extends AuthState{
  final User user;

  AuthUser(this.user);

  @override
  List<Object> get props => [user];
}
