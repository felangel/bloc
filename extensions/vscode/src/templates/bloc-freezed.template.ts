import * as changeCase from "change-case";

export function getFreezedBlocState(blocName: string): string {
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

export function getFreezedBlocTemplate(blocName: string) {
  const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
  const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
  const blocState = `${pascalCaseBlocName}State`;
  const blocEvent = `${pascalCaseBlocName}Event`;
  return `import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';
part '${snakeCaseBlocName}_event.dart';
part '${snakeCaseBlocName}_state.dart';
part '${snakeCaseBlocName}_bloc.freezed.dart';
class ${pascalCaseBlocName}Bloc extends Bloc<${blocEvent}, ${blocState}> {
  ${pascalCaseBlocName}Bloc() : super(_Initial());
  @override
  Stream<${blocState}> mapEventToState(
    ${blocEvent} event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
`;
}

export function getFreezedBlocEvent(blocName: string): string {
  const pascalCaseBlocName =
    changeCase.pascalCase(blocName.toLowerCase()) + "Event";
  const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
  return `part of '${snakeCaseBlocName}_bloc.dart';
@freezed
abstract class ${pascalCaseBlocName} with _\$${pascalCaseBlocName} {
  const factory ${pascalCaseBlocName}.event1() = Event1;
}`;
}
