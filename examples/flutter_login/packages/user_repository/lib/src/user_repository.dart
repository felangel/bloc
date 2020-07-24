import 'dart:async';

import 'package:uuid/uuid.dart';

import 'models/models.dart';

class UserRepository {
  User _user;

  Future<User> getUser() async {
    if (_user != null) return _user;
    return Future.delayed(
      const Duration(milliseconds: 300),
      () => _user = User(Uuid().v4()),
    );
  }
}
