part of '{{name.snakeCase()}}_bloc.dart';

abstract class {{name.pascalCase()}}Event {{#use_equatable}}extends Equatable{{/use_equatable}}{
  const {{name.pascalCase()}}Event();
  {{#use_equatable}}
  @override
  List<Object?> get props => [];
  {{/use_equatable}}
}
