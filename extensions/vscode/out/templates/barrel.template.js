"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const changeCase = require("change-case");
function getBarrelTemplate(blocName) {
    const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
    return `export '${snakeCaseBlocName}_bloc.dart';
export '${snakeCaseBlocName}_event.dart';
export '${snakeCaseBlocName}_state.dart';
`;
}
exports.getBarrelTemplate = getBarrelTemplate;
//# sourceMappingURL=barrel.template.js.map