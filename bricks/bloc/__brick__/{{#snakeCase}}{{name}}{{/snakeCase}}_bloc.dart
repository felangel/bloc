import 'package:bloc/bloc.dart';

part '{{#snakeCase}}{{name}}{{/snakeCase}}_event.dart';
part '{{#snakeCase}}{{name}}{{/snakeCase}}_state.dart';

class {{#pascalCase}}{{name}}{{/pascalCase}}Bloc extends Bloc<{{#pascalCase}}{{name}}{{/pascalCase}}Event, {{#pascalCase}}{{name}}{{/pascalCase}}State> {
  {{#pascalCase}}{{name}}{{/pascalCase}}Bloc() : super(const {{#pascalCase}}{{name}}{{/pascalCase}}State()) {
    on<{{#pascalCase}}{{name}}{{/pascalCase}}Event>((event, emit) {
      // TODO: implement event handler
    });
  }
}