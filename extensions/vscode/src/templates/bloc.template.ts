import * as changeCase from "change-case";
import { BlocType } from "../utils";

export function getBlocTemplate(blocName: string, type: BlocType, blocImportPath: string): string {
  switch (type) {
    case BlocType.Freezed:
      return getFreezedBlocTemplate(blocName, blocImportPath);
    case BlocType.Equatable:
      return getEquatableBlocTemplate(blocName, blocImportPath);
    default:
      return getDefaultBlocTemplate(blocName, blocImportPath);
  }
}

function getEquatableBlocTemplate(blocName: string, blocImportPath: string) {
  const pascalCaseBlocName = changeCase.pascalCase(blocName);
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  const blocState = `${pascalCaseBlocName}State`;
  const blocEvent = `${pascalCaseBlocName}Event`;
  return `${blocImportPath}
import 'package:equatable/equatable.dart';

part '${snakeCaseBlocName}_event.dart';
part '${snakeCaseBlocName}_state.dart';

class ${pascalCaseBlocName}Bloc extends Bloc<${blocEvent}, ${blocState}> {
  ${pascalCaseBlocName}Bloc() : super(${pascalCaseBlocName}Initial()) {
    on<${blocEvent}>((event, emit) {
      // TODO: implement event handler
    });
  }
}
`;
}

function getDefaultBlocTemplate(blocName: string, blocImportPath: string) {
  const pascalCaseBlocName = changeCase.pascalCase(blocName);
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  const blocState = `${pascalCaseBlocName}State`;
  const blocEvent = `${pascalCaseBlocName}Event`;
  return `${blocImportPath}
import 'package:meta/meta.dart';

part '${snakeCaseBlocName}_event.dart';
part '${snakeCaseBlocName}_state.dart';

class ${pascalCaseBlocName}Bloc extends Bloc<${blocEvent}, ${blocState}> {
  ${pascalCaseBlocName}Bloc() : super(${pascalCaseBlocName}Initial()) {
    on<${blocEvent}>((event, emit) {
      // TODO: implement event handler
    });
  }
}
`;
}

export function getFreezedBlocTemplate(blocName: string, blocImportPath: string) {
  const pascalCaseBlocName = changeCase.pascalCase(blocName);
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  const blocState = `${pascalCaseBlocName}State`;
  const blocEvent = `${pascalCaseBlocName}Event`;
  return `${blocImportPath}
import 'package:freezed_annotation/freezed_annotation.dart';

part '${snakeCaseBlocName}_event.dart';
part '${snakeCaseBlocName}_state.dart';
part '${snakeCaseBlocName}_bloc.freezed.dart';

class ${pascalCaseBlocName}Bloc extends Bloc<${blocEvent}, ${blocState}> {
  ${pascalCaseBlocName}Bloc() : super(_Initial()) {
    on<${blocEvent}>((event, emit) {
      // TODO: implement event handler
    });
  }
}
`;
}
