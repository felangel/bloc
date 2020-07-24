import 'dart:async';

import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'models/models.dart';

class AuthenticationRepository {
  final _controller = StreamController<User>();
  User _user;

  User get currentUser => _user;

  Stream<User> get user async* {
    yield _user;
    yield* _controller.stream;
  }

  Future<void> logIn({
    @required String username,
    @required String password,
  }) async {
    assert(username != null);
    assert(password != null);

    final user = await Future.delayed(
      const Duration(milliseconds: 300),
      () async => User(Uuid().v4()),
    );

    _controller.add(user);
    _user = user;
  }

  Future<void> logOut() async {
    if (_user != null) {
      _user = null;
      _controller.add(null);
    }
  }

  void close() => _controller.close();
}
