import * as changeCase from "change-case";
import { BlocType } from "../utils";

export function getBlocStateTemplate(blocName: string, type: BlocType): string {
  switch (type) {
    case BlocType.Freezed:
      return getFreezedBlocStateTemplate(blocName);
    case BlocType.Equatable:
      return getEquatableBlocStateTemplate(blocName);
    default:
      return getDefaultBlocStateTemplate(blocName);
  }
}

function getEquatableBlocStateTemplate(blocName: string): string {
  const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
  const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
  return `part of '${snakeCaseBlocName}_bloc.dart';

abstract class ${pascalCaseBlocName}State extends Equatable {
  const ${pascalCaseBlocName}State();
  
  @override
  List<Object> get props => [];
}

class ${pascalCaseBlocName}Initial extends ${pascalCaseBlocName}State {}
`;
}

function getDefaultBlocStateTemplate(blocName: string): string {
  const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
  const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
  return `part of '${snakeCaseBlocName}_bloc.dart';

@immutable
abstract class ${pascalCaseBlocName}State {}

class ${pascalCaseBlocName}Initial extends ${pascalCaseBlocName}State {}
`;
}

function getFreezedBlocStateTemplate(blocName: string): string {
  const pascalCaseBlocName =
    changeCase.pascalCase(blocName.toLowerCase()) + "State";
  const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
  return `part of '${snakeCaseBlocName}_bloc.dart';

@freezed
class ${pascalCaseBlocName} with _\$${pascalCaseBlocName} {
  const factory ${pascalCaseBlocName}.initial() = _Initial;
}
`;
}
