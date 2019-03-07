"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const changeCase = require("change-case");
function getBlocEventTemplate(blocName, useEquatable) {
    return useEquatable
        ? getEquatableBlocEventTemplate(blocName)
        : getDefaultBlocEventTemplate(blocName);
}
exports.getBlocEventTemplate = getBlocEventTemplate;
function getEquatableBlocEventTemplate(blocName) {
    const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
    return `import 'package:equatable/equatable.dart';

abstract class ${pascalCaseBlocName}Event extends Equatable {
  ${pascalCaseBlocName}Event([List props = const []]) : super(props);
}
`;
}
function getDefaultBlocEventTemplate(blocName) {
    const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
    return `abstract class ${pascalCaseBlocName}Event {}
`;
}
//# sourceMappingURL=bloc-event.template.js.map