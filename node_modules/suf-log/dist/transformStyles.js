"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.transformToBrowserStyle = exports.transformToNodeStyle = void 0;
var utils_1 = require("./utils");
function transformToNodeStyle(style) {
    if (typeof style === 'string') {
        return "\u001B[" + handleUndefined(utils_1.stringColorToAnsiColor('color', style)).replace(/;$/, '') + "m";
    }
    else {
        var codes = "" + addBoldStyle(style) + handleUndefined(utils_1.stringColorToAnsiColor('color', style.color)) + handleUndefined(utils_1.stringColorToAnsiColor('background', style.background));
        return "\u001B[" + codes.replace(/;$/, '') + "m";
    }
}
exports.transformToNodeStyle = transformToNodeStyle;
function addBoldStyle(style) {
    return style['font-weight'] === 'bold' ? utils_1.ANSICodes('bold') + ";" : '';
}
function handleUndefined(input) {
    return input ? input : '';
}
function transformToBrowserStyle(style) {
    if (style == undefined)
        return '';
    if (typeof style === 'string') {
        return "color: " + style + ";";
    }
    var out = '';
    if (!('display' in style)) {
        out += "display: inline-block; ";
    }
    for (var key in style) {
        if (Object.prototype.hasOwnProperty.call(style, key)) {
            out += key + ": " + style[key] + "; ";
        }
    }
    return out;
}
exports.transformToBrowserStyle = transformToBrowserStyle;
