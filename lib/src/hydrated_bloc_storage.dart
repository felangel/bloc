abstract class HydratedBlocStorage {
  String read(String key);
  void write(String key, String value);
}
