import * as changeCase from "change-case";
import { BlocType } from "../utils";

export function getBlocEventTemplate(blocName: string, type: BlocType): string {
  switch (type) {
    case BlocType.Freezed:
      return getFreezedBlocEvent(blocName);
    case BlocType.Equatable:
      return getEquatableBlocEventTemplate(blocName);
    default:
      return getDefaultBlocEventTemplate(blocName);
  }
}

function getEquatableBlocEventTemplate(blocName: string): string {
  const pascalCaseBlocName = changeCase.pascalCase(blocName);
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  return `part of '${snakeCaseBlocName}_bloc.dart';

abstract class ${pascalCaseBlocName}Event extends Equatable {
  const ${pascalCaseBlocName}Event();

  @override
  List<Object> get props => [];
}
`;
}

function getDefaultBlocEventTemplate(blocName: string): string {
  const pascalCaseBlocName = changeCase.pascalCase(blocName);
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  return `part of '${snakeCaseBlocName}_bloc.dart';

@immutable
abstract class ${pascalCaseBlocName}Event {}
`;
}

function getFreezedBlocEvent(blocName: string): string {
  const pascalCaseBlocName = changeCase.pascalCase(blocName) + "Event";
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  return `part of '${snakeCaseBlocName}_bloc.dart';

@freezed
class ${pascalCaseBlocName} with _\$${pascalCaseBlocName} {
  const factory ${pascalCaseBlocName}.started() = _Started;
}`;
}
