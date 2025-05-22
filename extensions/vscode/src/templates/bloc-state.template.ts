import * as changeCase from "change-case";
import { BlocType } from "../utils";

export function getBlocStateTemplate(
  blocName: string,
  type: BlocType,
  useSealedClasses: boolean,
  useUnionTypes: boolean,
): string {
  switch (type) {
    case BlocType.Freezed:
      return getFreezedBlocStateTemplate(
        blocName,
        useSealedClasses,
        useUnionTypes,
      );
    case BlocType.Equatable:
      return getEquatableBlocStateTemplate(blocName, useSealedClasses);
    default:
      return getDefaultBlocStateTemplate(blocName, useSealedClasses);
  }
}

function getEquatableBlocStateTemplate(
  blocName: string,
  useSealedClasses: boolean
): string {
  const classPrefix = useSealedClasses ? "sealed" : "abstract";
  const subclassPrefix = useSealedClasses ? "final " : "";
  const pascalCaseBlocName = changeCase.pascalCase(blocName);
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  return `part of '${snakeCaseBlocName}_bloc.dart';

${classPrefix} class ${pascalCaseBlocName}State extends Equatable {
  const ${pascalCaseBlocName}State();
  
  @override
  List<Object> get props => [];
}

${subclassPrefix}class ${pascalCaseBlocName}Initial extends ${pascalCaseBlocName}State {}
`;
}

function getDefaultBlocStateTemplate(
  blocName: string,
  useSealedClasses: boolean
): string {
  const classPrefix = useSealedClasses ? "sealed" : "abstract";
  const subclassPrefix = useSealedClasses ? "final " : "";
  const pascalCaseBlocName = changeCase.pascalCase(blocName);
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  return `part of '${snakeCaseBlocName}_bloc.dart';

@immutable
${classPrefix} class ${pascalCaseBlocName}State {}

${subclassPrefix}class ${pascalCaseBlocName}Initial extends ${pascalCaseBlocName}State {}
`;
}

function getFreezedBlocStateTemplate(
  blocName: string,
  useSealedClasses: boolean,
  useUnionTypes: boolean,
): string {
  const pascalCaseBlocName = changeCase.pascalCase(blocName) + "State";
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  const classPrefix = useSealedClasses ? "sealed " : "";

  if (useUnionTypes) {
    return `part of '${snakeCaseBlocName}_bloc.dart';

@freezed
${classPrefix}class ${pascalCaseBlocName} with _\$${pascalCaseBlocName} {
  const factory ${pascalCaseBlocName}.initial() = _Initial;
}
`;
  }
  return `part of '${snakeCaseBlocName}_bloc.dart';

@freezed
${classPrefix}class ${pascalCaseBlocName} with _\$${pascalCaseBlocName} {
  const factory ${pascalCaseBlocName}() = _${pascalCaseBlocName};
}
`;
}
