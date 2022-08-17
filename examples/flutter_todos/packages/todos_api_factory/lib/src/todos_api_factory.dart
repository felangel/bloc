import 'package:local_storage_todos_api/local_storage_todos_api.dart';
import 'package:todos_api/todos_api.dart';

enum _Implementation { localStorage, firestore }

/// Factory for a specific implementation provided by Todos API
extension TodosApiFactory on TodosApi {
  /// Provide concreate [implementation] of TodosApi
  static Future<TodosApi> factory(String implementation) async {
    final api = _Implementation.values.byName(implementation);

    switch (api) {
      case _Implementation.localStorage:
        return LocalStorageTodosApi(
          plugin: await SharedPreferences.getInstance(),
        );
      case _Implementation.firestore:
        // TODO: Handle this case.
        break;
    }

    throw Exception('Failed to instansiate API');
  }
}
