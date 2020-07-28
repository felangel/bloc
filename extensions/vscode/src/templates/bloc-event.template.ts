import * as changeCase from "change-case";
import { Dependency } from "../consts/dependency_enum";

export function getBlocEventTemplate(
  blocName: string,
  dependency: Dependency
): string {
  switch (dependency) {
    case Dependency.Freezed:
      return getFreezedBlocEvent(blocName);
    case Dependency.Equatable:
      return getEquatableBlocEventTemplate(blocName);
    default:
      return getDefaultBlocEventTemplate(blocName);
  }
}

function getEquatableBlocEventTemplate(blocName: string): string {
  const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
  const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
  return `part of '${snakeCaseBlocName}_bloc.dart';

abstract class ${pascalCaseBlocName}Event extends Equatable {
  const ${pascalCaseBlocName}Event();
}
`;
}

function getDefaultBlocEventTemplate(blocName: string): string {
  const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
  const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
  return `part of '${snakeCaseBlocName}_bloc.dart';

@immutable
abstract class ${pascalCaseBlocName}Event {}
`;
}

function getFreezedBlocEvent(blocName: string): string {
  const pascalCaseBlocName =
    changeCase.pascalCase(blocName.toLowerCase()) + "Event";
  const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
  return `part of '${snakeCaseBlocName}_bloc.dart';

@freezed
abstract class ${pascalCaseBlocName} with _\$${pascalCaseBlocName} {
  const factory ${pascalCaseBlocName}.started() = _Started;
}`;
}
