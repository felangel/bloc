import 'package:flutter/widgets.dart';
import 'package:flutter_todos/bootstrap.dart';
import 'package:todos_api_factory/todos_api_factory.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  const implementation =
      String.fromEnvironment('todos_api', defaultValue: 'localStorage');

  final todosApi = await TodosApiFactory.factory(implementation);

  bootstrap(todosApi: todosApi);
}
