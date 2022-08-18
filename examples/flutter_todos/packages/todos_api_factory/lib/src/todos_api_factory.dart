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
  /// implementation is [localStorage | firestore]
  ///
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

        /// # Firestore 😱🥰
        ///
        /// THIS WAS SECTION WAS WRITTEN BY A DRUNK CODER.
        ///
        /// Flutter Firebase supports 2 approches for initialisation:
        ///  1. "as code" (Reading from DefaultFirebaseOptions)
        ///  2. "creds file" (Native library reads google-service)
        ///
        /// *All* native firebase  modules (firestore, auth, crashlytics, etc..)
        /// support `creds file` approach.
        ///
        /// *Some* native firebase  modules (firestore, auth) support `as code`
        /// approach, while others (for ex. crashlytics) do not.
        ///
        /// *None* of the firebase web modules support the `creds file` approch.
        ///
        /// As such, Flutter Firebase de-facto ships with best effort dual
        /// initialisation + runtime error handling. We follow suite.
        ///
        /// Better compile time error handling could be offered here as we hold
        /// more context, i.e. For the case when the target platform is Web but
        /// and [options] is null.
        final firebaseOptions = (options is FirebaseOptions) ? options : null;

        await Firebase.initializeApp(options: firebaseOptions);
        final todosApi =
            FirestoreTodosApi(firestore: FirebaseFirestore.instance);

        return todosApi;
    }
  }
}
