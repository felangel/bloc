{{#use_equatable}}import 'package:equatable/equatable.dart';{{/use_equatable}}
import 'package:bloc/bloc.dart';

part '{{name.snakeCase()}}_event.dart';
part '{{name.snakeCase()}}_state.dart';

class {{name.pascalCase()}}Bloc extends Bloc<{{name.pascalCase()}}Event, {{name.pascalCase()}}State> {
  {{name.pascalCase()}}Bloc() : super(const {{name.pascalCase()}}State()) {
    on<{{name.pascalCase()}}Event>((event, emit) {
    // TODO: implement event handler
    });

    {{#events}}on<{{eventName.pascalCase()}}>((event, emit) {
      // TODO: implement event handler
    });
    {{/events}}
  }
}





