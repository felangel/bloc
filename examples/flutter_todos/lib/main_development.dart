import 'package:args/args.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_todos/bootstrap.dart';
import 'package:todos_api_factory/todos_api_factory.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final parser = ArgParser()
    ..addOption(
      'todos_api',
      help: 'The concreate implemeneation of TodosAPI to use',
      allowed: ['localStorage', 'firestore'],
      defaultsTo: 'localStorage',
    );

  final parameters = parser.parse(args);
  final implementation = parameters['todos_api'] as String;

  final todosApi = await TodosApiFactory.factory(implementation);

  bootstrap(todosApi: todosApi);
}
