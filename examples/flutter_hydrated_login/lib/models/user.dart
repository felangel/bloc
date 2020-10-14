import 'dart:convert';

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uuid;
  final String email;
  final String password;

  User({this.uuid, this.email, this.password});

  @override
  List<Object> get props => [uuid, email, password];

  factory User.fromJson(Map json) {
    return User(
        uuid: json['uuid'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '');
  }

  static Map<String, dynamic> toMap(User user) {
    return {'uuid': user.uuid, 'email': user.email, 'password': user.password};
  }
}
