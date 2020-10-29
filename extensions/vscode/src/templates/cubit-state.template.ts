import * as changeCase from "change-case";
import { BlocType } from "../utils";

export function getCubitStateTemplate(
  cubitName: string,
  type: BlocType
): string {
  switch (type) {
    case BlocType.Freezed:
      return getFreezedCubitStateTemplate(cubitName);
    case BlocType.Equatable:
      return getEquatableCubitStateTemplate(cubitName);
    default:
      return getDefaultCubitStateTemplate(cubitName);
  }
}

function getEquatableCubitStateTemplate(cubitName: string): string {
  const pascalCaseCubitName = changeCase.pascalCase(cubitName.toLowerCase());
  const snakeCaseCubitName = changeCase.snakeCase(cubitName.toLowerCase());
  return `part of '${snakeCaseCubitName}_cubit.dart';

abstract class ${pascalCaseCubitName}State extends Equatable {
  const ${pascalCaseCubitName}State();

  @override
  List<Object> get props => [];
}

class ${pascalCaseCubitName}Initial extends ${pascalCaseCubitName}State {}
`;
}

function getDefaultCubitStateTemplate(cubitName: string): string {
  const pascalCaseCubitName = changeCase.pascalCase(cubitName.toLowerCase());
  const snakeCaseCubitName = changeCase.snakeCase(cubitName.toLowerCase());
  return `part of '${snakeCaseCubitName}_cubit.dart';

@immutable
abstract class ${pascalCaseCubitName}State {}

class ${pascalCaseCubitName}Initial extends ${pascalCaseCubitName}State {}
`;
}

function getFreezedCubitStateTemplate(cubitName: string): string {
  const pascalCaseCubitName = changeCase.pascalCase(cubitName.toLowerCase());
  const snakeCaseCubitName = changeCase.snakeCase(cubitName.toLowerCase());
  return `part of '${snakeCaseCubitName}_cubit.dart';

@freezed
abstract class ${pascalCaseCubitName}State with _\$${pascalCaseCubitName}State {
  const factory ${pascalCaseCubitName}State.initial() = _Initial;
}
`;
}
