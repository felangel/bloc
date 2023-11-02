import * as changeCase from "change-case";
import { BlocType } from "../utils";

export function getBlocEventTemplate(
  blocName: string,
  type: BlocType,
  useSealedClasses: boolean
): string {
  switch (type) {
    case BlocType.Freezed:
      return getFreezedBlocEvent(blocName);
    case BlocType.Equatable:
      return getEquatableBlocEventTemplate(blocName, useSealedClasses);
    default:
      return getDefaultBlocEventTemplate(blocName, useSealedClasses);
  }
}

function getEquatableBlocEventTemplate(
  blocName: string,
  useSealedClasses: boolean
): string {
  const classPrefix = useSealedClasses ? "sealed" : "abstract";
  const pascalCaseBlocName = changeCase.pascalCase(blocName);
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  return `part of '${snakeCaseBlocName}_bloc.dart';

${classPrefix} class ${pascalCaseBlocName}Event extends Equatable {
  const ${pascalCaseBlocName}Event();

  @override
  List<Object> get props => [];
}
`;
}

function getDefaultBlocEventTemplate(
  blocName: string,
  useSealedClasses: boolean
): string {
  const classPrefix = useSealedClasses ? "sealed" : "abstract";
  const pascalCaseBlocName = changeCase.pascalCase(blocName);
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  return `part of '${snakeCaseBlocName}_bloc.dart';

@immutable
${classPrefix} class ${pascalCaseBlocName}Event {}
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
