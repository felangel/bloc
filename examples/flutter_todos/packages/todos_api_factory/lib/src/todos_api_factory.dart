import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firestore_todos_api/firestore_todos_api.dart';
import 'package:local_storage_todos_api/local_storage_todos_api.dart';
import 'package:todos_api/todos_api.dart';

enum _Implementation { localStorage, firestore }

/// Factory for a specific implementation provided by Todos API
extension TodosApiFactory on TodosApi {
  /// Provide concreate [implementation] of TodosApi. Use [options] to pass
  /// initialisation options.
  ///
  /// # firestore
  /// THIS WAS SECTION WAS WRITTEN BY A DRUNK CODER.
  ///
  /// Flutter Firebase supports initialisation in 2 methods:
  ///  1. as code (Reading from DefaultFirebaseOptions)
  ///  2. creds file (Native lib reads from google-service.json)
  ///
  /// All native firebase  modules (firestore, auth, crashlytics, etc..)
  /// support `creds file` approach. Some (firestore, auth) native modules
  /// support `as code` initialisation, while others (for ex. crashlytics) do
  /// not. NONE of the firebase web modules support the `creds file` approch.
  ///
  /// As such Flutter Firebase de-facto ships with support for both options,
  /// and we follow suite. However better error handling can be offered for the
  /// case when we on Web without `as code` initialisation provided.
  static Future<TodosApi> factory(
    String implementation, {
    dynamic options,
  }) async {
    final api = _Implementation.values.byName(implementation);

    switch (api) {
      case _Implementation.localStorage:
        final todosApi = LocalStorageTodosApi(
          plugin: await SharedPreferences.getInstance(),
        );

        return todosApi;
      case _Implementation.firestore:
        final firebaseOptions = (options is FirebaseOptions) ? options : null;

        await Firebase.initializeApp(options: firebaseOptions);
        final todosApi =
            FirestoreTodosApi(firestore: FirebaseFirestore.instance);

        return todosApi;
    }
  }
}
