abstract class UserRepository {
  Future<bool> isAuthenticated();

  Future<void> authenticate();

  Future<String> getUserId();
}
