import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todos/home/view/home_page.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:flutter_todos/theme/theme.dart';
import 'package:todos_api/todos_api.dart';
// ignore: directives_ordering, implementation_imports
import 'package:todos_api/src/models/concrete_todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

final todosApiProvider = Provider<TodosApi>((ref) => ConcreteTodosApi());

final todosRepositoryProvider = Provider<TodosRepository>(
  (ref) => TodosRepository(todosApi: ref.watch(todosApiProvider)),
);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
        theme: FlutterTodosTheme.light,
        darkTheme: FlutterTodosTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomePage(),
      );
}
