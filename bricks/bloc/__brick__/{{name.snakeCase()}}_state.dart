part of '{{name.snakeCase()}}_bloc.dart';

class {{name.pascalCase()}}State {{#use_equatable}}extends Equatable{{/use_equatable}}{
  const {{name.pascalCase()}}State();
  {{#use_equatable}}
  @override
  List<Object?> get props => [];
  {{/use_equatable}}
}
