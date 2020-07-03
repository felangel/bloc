import * as changeCase from "change-case";

export function getCubitStateTemplate(
  cubitName: string,
  useEquatable: boolean
): string {
  return useEquatable
    ? getEquatableCubitStateTemplate(cubitName)
    : getDefaultCubitStateTemplate(cubitName);
}

function getEquatableCubitStateTemplate(cubitName: string): string {
  const pascalCaseCubitName = changeCase.pascalCase(cubitName.toLowerCase());
  const snakeCaseCubitName = changeCase.snakeCase(cubitName.toLowerCase());
  return `part of '${snakeCaseCubitName}_cubit.dart';

abstract class ${pascalCaseCubitName}State extends Equatable {
  const ${pascalCaseCubitName}State();
}

class ${pascalCaseCubitName}Initial extends ${pascalCaseCubitName}State {
  @override
  List<Object> get props => [];
}
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
