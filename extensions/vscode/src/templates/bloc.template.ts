import * as changeCase from "change-case";

export function getBlocTemplate(blocName: string): string {
  const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
  const blocState = `${pascalCaseBlocName}State`;
  const blocEvent = `${pascalCaseBlocName}Event`;
  return `import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class ${pascalCaseBlocName}Bloc extends Bloc<${blocEvent}, ${blocState}> {
  @override
  ${blocState} get initialState => Initial${blocState}();

  @override
  Stream<${blocState}> mapEventToState(
    ${blocEvent} event,
  ) async* {
    // TODO: Add Logic
  }
}
`;
}
