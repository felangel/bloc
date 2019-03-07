"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const changeCase = require("change-case");
function getBlocTemplate(blocName) {
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
    ${blocState} currentState,
    ${blocEvent} event,
  ) async* {
    // TODO: Replace with custom logic
    yield currentState;
  }
}
`;
}
exports.getBlocTemplate = getBlocTemplate;
//# sourceMappingURL=bloc.template.js.map