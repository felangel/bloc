import * as changeCase from "change-case";
import { BlocType } from "../utils";

export function getCubitTemplate(cubitName: string, type: BlocType): string {
  switch (type) {
    case BlocType.Freezed:
      return getFreezedCubitTemplate(cubitName);
    case BlocType.Equatable:
      return getEquatableCubitTemplate(cubitName);
    default:
      return getDefaultCubitTemplate(cubitName);
  }
}

function getEquatableCubitTemplate(cubitName: string) {
  const pascalCaseCubitName = changeCase.pascalCase(cubitName);
  const snakeCaseCubitName = changeCase.snakeCase(cubitName);
  const cubitState = `${pascalCaseCubitName}State`;
  return `import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '${snakeCaseCubitName}_state.dart';

class ${pascalCaseCubitName}Cubit extends Cubit<${cubitState}> {
  ${pascalCaseCubitName}Cubit() : super(${pascalCaseCubitName}Initial());
}
`;
}

function getDefaultCubitTemplate(cubitName: string) {
  const pascalCaseCubitName = changeCase.pascalCase(cubitName);
  const snakeCaseCubitName = changeCase.snakeCase(cubitName);
  const cubitState = `${pascalCaseCubitName}State`;
  return `import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part '${snakeCaseCubitName}_state.dart';

class ${pascalCaseCubitName}Cubit extends Cubit<${cubitState}> {
  ${pascalCaseCubitName}Cubit() : super(${pascalCaseCubitName}Initial());
}
`;
}

export function getFreezedCubitTemplate(cubitName: string) {
  const pascalCaseCubitName = changeCase.pascalCase(cubitName);
  const snakeCaseCubitName = changeCase.snakeCase(cubitName);
  const cubitState = `${pascalCaseCubitName}State`;
  return `import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '${snakeCaseCubitName}_state.dart';
part '${snakeCaseCubitName}_cubit.freezed.dart';

class ${pascalCaseCubitName}Cubit extends Cubit<${cubitState}> {
  ${pascalCaseCubitName}Cubit() : super(${pascalCaseCubitName}State.initial());
}
`;
}
