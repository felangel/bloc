import * as changeCase from "change-case";
import { BlocType } from "../utils";

export function getCubitTemplate(cubitName: string, type: BlocType, blocImportPath: string): string {
  switch (type) {
    case BlocType.Freezed:
      return getFreezedCubitTemplate(cubitName, blocImportPath);
    case BlocType.Equatable:
      return getEquatableCubitTemplate(cubitName, blocImportPath);
    default:
      return getDefaultCubitTemplate(cubitName, blocImportPath);
  }
}

function getEquatableCubitTemplate(cubitName: string, blocImportPath: string) {
  const pascalCaseCubitName = changeCase.pascalCase(cubitName);
  const snakeCaseCubitName = changeCase.snakeCase(cubitName);
  const cubitState = `${pascalCaseCubitName}State`;
  return `${blocImportPath}
import 'package:equatable/equatable.dart';

part '${snakeCaseCubitName}_state.dart';

class ${pascalCaseCubitName}Cubit extends Cubit<${cubitState}> {
  ${pascalCaseCubitName}Cubit() : super(${pascalCaseCubitName}Initial());
}
`;
}

function getDefaultCubitTemplate(cubitName: string, blocImportPath: string) {
  const pascalCaseCubitName = changeCase.pascalCase(cubitName);
  const snakeCaseCubitName = changeCase.snakeCase(cubitName);
  const cubitState = `${pascalCaseCubitName}State`;
  return `${blocImportPath}
import 'package:meta/meta.dart';

part '${snakeCaseCubitName}_state.dart';

class ${pascalCaseCubitName}Cubit extends Cubit<${cubitState}> {
  ${pascalCaseCubitName}Cubit() : super(${pascalCaseCubitName}Initial());
}
`;
}

export function getFreezedCubitTemplate(cubitName: string, blocImportPath: string) {
  const pascalCaseCubitName = changeCase.pascalCase(cubitName);
  const snakeCaseCubitName = changeCase.snakeCase(cubitName);
  const cubitState = `${pascalCaseCubitName}State`;
  return `${blocImportPath}
import 'package:freezed_annotation/freezed_annotation.dart';

part '${snakeCaseCubitName}_state.dart';
part '${snakeCaseCubitName}_cubit.freezed.dart';

class ${pascalCaseCubitName}Cubit extends Cubit<${cubitState}> {
  ${pascalCaseCubitName}Cubit() : super(${pascalCaseCubitName}State.initial());
}
`;
}
