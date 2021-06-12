abstract class UserRepository {
  Future<bool> isAuthenticated();

  Future<void> authenticate();

  String? getUserId();
}
