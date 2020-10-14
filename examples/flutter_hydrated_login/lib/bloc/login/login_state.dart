import 'package:equatable/equatable.dart';
import 'package:flutter_hydrated_login/models/user.dart';
import 'package:regexpattern/regexpattern.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginError extends LoginState {
  final String txt;
  LoginError(this.txt);
}

class LoginUser extends LoginState {
  final String uuid;
  final String email;
  final String password;

  LoginUser({this.email, this.password, this.uuid});

  @override
  List<Object> get props => [uuid, email, password];
}

class MyFormChange extends LoginState {
  final String email;
  final String password;
  final bool isActive;
  final UserState userState;

  MyFormChange(
      {this.email, this.password, this.userState, this.isActive = false});

  @override
  List<Object> get props => [email, password, userState, isActive];

  MyFormChange copyWith(
      {String emailNew, String passNew, UserState user, bool isNewActivate}) {
    return MyFormChange(
        email: emailNew ?? this.email,
        password: passNew ?? this.password,
        isActive: isNewActivate ?? this.isActive,
        userState: user ?? this.userState);
  }

  String emailValidation() {
    if (email != null && email.isNotEmpty && !email.isEmail()) {
      return 'Not Format Email';
    }
    return null;
  }

  String passwordValidation() {
    if (password != null &&
        password.isNotEmpty &&
        !password.isPasswordNormal1()) {
      return 'Password must containt number char';
    }
    return null;
  }
}

class UserState extends Equatable {
  final User user;
  UserState({this.user});

  @override
  List<Object> get props => [user];
}
