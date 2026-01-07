"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.styler = void 0;
var transformStyles_1 = require("./transformStyles");
var utils_1 = require("./utils");
/**
 * this function is not browser compatible*.
 * @example ```ts
 * console.log(styler('test', 'red'))
 * ```
 *
 * *you have to add the styles manually, use the Log function for browser compatibly.
 */
function styler(input, style) {
    if (utils_1.isBrowser) {
        return "%c" + input;
    }
    if (style) {
        return utils_1.addReset("" + transformStyles_1.transformToNodeStyle(style) + input);
    }
    return input;
}
exports.styler = styler;
