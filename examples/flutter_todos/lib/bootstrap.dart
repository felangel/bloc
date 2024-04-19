import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/app/app.dart';
import 'package:local_storage_todos_api/local_storage_todos_api.dart';
// ignore: implementation_imports
import 'package:todos_api/src/models/concrete_todos_api.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

final todosApiProvider = Provider<TodosApi>((ref) => ConcreteTodosApi());
final todosRepositoryProvider = Provider<TodosRepository>(
  (ref) => TodosRepository(todosApi: ref.watch(todosApiProvider)),
);

void bootstrap({required LocalStorageTodosApi todosApi}) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  runZonedGuarded(
    () => runApp(const ProviderScope(child: App())),
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
