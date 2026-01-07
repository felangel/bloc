"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
var utils_1 = require("./utils");
Object.defineProperty(exports, "SetEnvironment", { enumerable: true, get: function () { return utils_1.SetLoggerEnvironment; } });
Object.defineProperty(exports, "ANSICodes", { enumerable: true, get: function () { return utils_1.ANSICodes; } });
Object.defineProperty(exports, "removeNodeStyles", { enumerable: true, get: function () { return utils_1.removeNodeStyles; } });
var styler_1 = require("./styler");
Object.defineProperty(exports, "styler", { enumerable: true, get: function () { return styler_1.styler; } });
__exportStar(require("./loggers"), exports);
__exportStar(require("./interfaces"), exports);
__exportStar(require("./transformStyles"), exports);
