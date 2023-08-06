import * as changeCase from "change-case";
import { BlocType } from "../utils";

export function getCubitStateTemplate(
  cubitName: string,
  type: BlocType,
  useSealedClasses: boolean
): string {
  switch (type) {
    case BlocType.Freezed:
      return getFreezedCubitStateTemplate(cubitName);
    case BlocType.Equatable:
      return getEquatableCubitStateTemplate(cubitName, useSealedClasses);
    default:
      return getDefaultCubitStateTemplate(cubitName, useSealedClasses);
  }
}

function getEquatableCubitStateTemplate(
  cubitName: string,
  useSealedClasses: boolean
): string {
  const classPrefix = useSealedClasses ? "sealed" : "abstract";
  const subclassPrefix = useSealedClasses ? "final " : "";
  const pascalCaseCubitName = changeCase.pascalCase(cubitName);
  const snakeCaseCubitName = changeCase.snakeCase(cubitName);
  return `part of '${snakeCaseCubitName}_cubit.dart';

${classPrefix} class ${pascalCaseCubitName}State extends Equatable {
  const ${pascalCaseCubitName}State();

  @override
  List<Object> get props => [];
}

${subclassPrefix}class ${pascalCaseCubitName}Initial extends ${pascalCaseCubitName}State {}
`;
}

function getDefaultCubitStateTemplate(
  cubitName: string,
  useSealedClasses: boolean
): string {
  const classPrefix = useSealedClasses ? "sealed" : "abstract";
  const subclassPrefix = useSealedClasses ? "final " : "";
  const pascalCaseCubitName = changeCase.pascalCase(cubitName);
  const snakeCaseCubitName = changeCase.snakeCase(cubitName);
  return `part of '${snakeCaseCubitName}_cubit.dart';

@immutable
${classPrefix} class ${pascalCaseCubitName}State {}

${subclassPrefix}class ${pascalCaseCubitName}Initial extends ${pascalCaseCubitName}State {}
`;
}

function getFreezedCubitStateTemplate(cubitName: string): string {
  const pascalCaseCubitName = changeCase.pascalCase(cubitName);
  const snakeCaseCubitName = changeCase.snakeCase(cubitName);
  return `part of '${snakeCaseCubitName}_cubit.dart';

@freezed
class ${pascalCaseCubitName}State with _\$${pascalCaseCubitName}State {
  const factory ${pascalCaseCubitName}State.initial() = _Initial;
}
`;
}
