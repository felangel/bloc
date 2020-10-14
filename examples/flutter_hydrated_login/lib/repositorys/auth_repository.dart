import 'package:flutter_hydrated_login/models/user.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  AuthRepository();

  Future<User> fetchUser(String email, String password) async {
    final uuid = Uuid();
    final result = await Future.delayed(Duration(seconds: 1), () {
      return uuid.v1();
    });
    print(result);
    return User.fromJson(
        {'uuid': result, 'email': email, 'password': password});
  }
}
