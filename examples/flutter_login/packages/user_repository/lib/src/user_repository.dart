import 'dart:async';

import 'package:uuid/uuid.dart';

import 'models/models.dart';

class UserRepository {
  User _user;

  Future<User> getUser() async {
    if (_user != null) return _user;
    await Future.delayed(const Duration(milliseconds: 300));
    return _user = User(Uuid().v4());
  }
}
