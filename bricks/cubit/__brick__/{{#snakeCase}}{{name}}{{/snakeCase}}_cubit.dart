import 'package:bloc/bloc.dart';

part '{{#snakeCase}}{{name}}{{/snakeCase}}_state.dart';

class {{#pascalCase}}{{name}}{{/pascalCase}}Cubit extends Cubit<{{#pascalCase}}{{name}}{{/pascalCase}}State> {
  {{#pascalCase}}{{name}}{{/pascalCase}}Cubit() : super(const {{#pascalCase}}{{name}}{{/pascalCase}}State());
}