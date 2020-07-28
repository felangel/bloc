import * as changeCase from "change-case";
import { Dependency } from "../consts/dependency_enum";

export function getBlocStateTemplate(
  blocName: string,
  useDependcy: Dependency
): string {
  switch (dependency) {
    case Dependency.Freezed:
      return getFreezedBlocState(blocName);
    case Dependency.Equatable:
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
}

class ${pascalCaseBlocName}Initial extends ${pascalCaseBlocName}State {
  @override
  List<Object> get props => [];
}
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

function getFreezedBlocState(blocName: string): string {
  const pascalCaseBlocName =
    changeCase.pascalCase(blocName.toLowerCase()) + "State";
  const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
  return `part of '${snakeCaseBlocName}_bloc.dart';

@freezed
abstract class ${pascalCaseBlocName} with _\$${pascalCaseBlocName} {
  const factory ${pascalCaseBlocName}.inital() = _Initial;
  const factory ${pascalCaseBlocName}.loadInProgress() = _LoadInProgress;
  const factory ${pascalCaseBlocName}.loadSuccess() = _LoadSuccess;
  const factory ${pascalCaseBlocName}.loadFailure() = _LoadFailure;
}
`;
}
