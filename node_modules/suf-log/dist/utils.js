"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.addReset = exports.getColumn = exports.pad = exports.removeNodeStyles = exports.maxTableColumnLength = exports.ANSICodes = exports.stringColorToAnsiColor = exports.SetLoggerEnvironment = exports.defaultLogTableOptions = exports.isBrowser = void 0;
var s_color_1 = require("s.color");
exports.isBrowser = typeof window !== 'undefined' && typeof window.document !== 'undefined';
exports.defaultLogTableOptions = { padding: 0, spacing: 1 };
/**
 * Can be used to change the assumed environment
 */
function SetLoggerEnvironment(env) {
    exports.isBrowser = env === 'browser';
}
exports.SetLoggerEnvironment = SetLoggerEnvironment;
function stringColorToAnsiColor(type, color) {
    if (!color) {
        return undefined;
    }
    var _a = s_color_1.StringToRGB(color, true), r = _a.r, g = _a.g, b = _a.b;
    return ANSICodes(type) + ";2;" + r + ";" + g + ";" + b + ";";
}
exports.stringColorToAnsiColor = stringColorToAnsiColor;
function ANSICodes(type) {
    switch (type) {
        case 'reset':
            return '0';
        case 'bold':
            return '1';
        case 'color':
            return '38';
        case 'background':
            return '48';
    }
}
exports.ANSICodes = ANSICodes;
function maxTableColumnLength(column) {
    var max = 0;
    for (var i = 0; i < column.length; i++) {
        var field = column[i];
        if (field) {
            var length_1 = removeNodeStyles(typeof field === 'object' ? field.message : field).length;
            max = length_1 > max ? length_1 : max;
        }
    }
    return max;
}
exports.maxTableColumnLength = maxTableColumnLength;
function removeNodeStyles(item) {
    return item.toString().replace(/[\033\x1b\u001b]\[.*?m/g, '');
}
exports.removeNodeStyles = removeNodeStyles;
function pad(text, start, end) {
    var space = function (amount) { return ' '.repeat(amount); };
    return "" + space(start) + text + space(end);
}
exports.pad = pad;
function getColumn(matrix, col) {
    return matrix.map(function (row) { return row[col]; });
}
exports.getColumn = getColumn;
function addReset(input) {
    return input + "\u001B[0m";
}
exports.addReset = addReset;
