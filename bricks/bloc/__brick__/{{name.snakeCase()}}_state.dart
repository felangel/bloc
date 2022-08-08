part of '{{name.snakeCase()}}_bloc.dart';

abstract class {{name.pascalCase()}}State {{#use_equatable}}extends Equatable{{/use_equatable}} {
  const {{name.pascalCase()}}State();
  {{#use_equatable}}
  @override
  List<Object?> get props => [];
  {{/use_equatable}}
}

class {{name.pascalCase()}}Initial extends {{name.pascalCase()}}State {
  const {{name.pascalCase()}}Initial();
}
{{#states}}
class {{stateName.pascalCase()}} extends {{name.pascalCase()}}State {
  const {{stateName.pascalCase()}}();
}
{{/states}}