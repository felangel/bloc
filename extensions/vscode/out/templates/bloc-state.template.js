"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const changeCase = require("change-case");
function getBlocStateTemplate(blocName, useEquatable) {
    return useEquatable
        ? getEquatableBlocStateTemplate(blocName)
        : getDefaultBlocStateTemplate(blocName);
}
exports.getBlocStateTemplate = getBlocStateTemplate;
function getEquatableBlocStateTemplate(blocName) {
    const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
    return `import 'package:equatable/equatable.dart';

abstract class ${pascalCaseBlocName}State extends Equatable {
  ${pascalCaseBlocName}State([List props = const []]) : super(props);
}

class Initial${pascalCaseBlocName}State extends ${pascalCaseBlocName}State {}
`;
}
function getDefaultBlocStateTemplate(blocName) {
    const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
    return `abstract class ${pascalCaseBlocName}State {}
  
class Initial${pascalCaseBlocName}State extends ${pascalCaseBlocName}State {}
`;
}
//# sourceMappingURL=bloc-state.template.js.map