"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __spreadArrays = (this && this.__spreadArrays) || function () {
    for (var s = 0, i = 0, il = arguments.length; i < il; i++) s += arguments[i].length;
    for (var r = Array(s), k = 0, i = 0; i < il; i++)
        for (var a = arguments[i], j = 0, jl = a.length; j < jl; j++, k++)
            r[k] = a[j];
    return r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LogSingle = exports.LogS = exports.LogTable = exports.Log = void 0;
var utils_1 = require("./utils");
var _1 = require(".");
var transformStyles_1 = require("./transformStyles");
/**works in node and the browser.*/
function Log() {
    var messages = [];
    for (var _i = 0; _i < arguments.length; _i++) {
        messages[_i] = arguments[_i];
    }
    var output = '';
    var browserStyles = [];
    for (var i = 0; i < messages.length; i++) {
        var msg = messages[i];
        if (typeof msg === 'object') {
            if (utils_1.isBrowser) {
                var style = transformStyles_1.transformToBrowserStyle(msg.style);
                if (style)
                    browserStyles.push(style);
            }
            output += _1.styler(msg.message, msg.style);
        }
        else {
            output += msg;
        }
        if (i < messages.length - 1) {
            output += ' ';
        }
    }
    console.log.apply(console, __spreadArrays([output], browserStyles));
}
exports.Log = Log;
/**node only*/
function LogTable(table, options) {
    if (options === void 0) { options = utils_1.defaultLogTableOptions; }
    if (table[0] === undefined)
        return;
    var _a = __assign(__assign({}, utils_1.defaultLogTableOptions), options), padding = _a.padding, spacing = _a.spacing;
    var output = '';
    var maxLengths = [];
    for (var i = 0; i < table[0].length; i++) {
        var column = utils_1.getColumn(table, i);
        maxLengths.push(utils_1.maxTableColumnLength(column));
    }
    for (var i = 0; i < table.length; i++) {
        var row = table[i];
        for (var j = 0; j < row.length; j++) {
            var field = row[j];
            var text = '';
            var style = void 0;
            if (typeof field === 'object') {
                style = field.style;
                text = field.message;
            }
            else {
                text = field.toString();
            }
            var startPadding = j === 0 ? padding : 0;
            var endPadding = maxLengths[j] + (j === row.length - 1 ? padding : spacing);
            var textLength = utils_1.removeNodeStyles(text).length;
            var paddedText = utils_1.pad(text, startPadding, endPadding - textLength);
            if (style) {
                output += _1.styler(paddedText, style);
            }
            else {
                output += paddedText;
            }
        }
        output += '\n';
    }
    console.log(output.replace(/\n$/, ''));
}
exports.LogTable = LogTable;
/**works in the browser and node. */
function LogS(styles) {
    var messages = [];
    for (var _i = 1; _i < arguments.length; _i++) {
        messages[_i - 1] = arguments[_i];
    }
    var browserStyles = [];
    var output = '';
    for (var i = 0; i < messages.length; i++) {
        var msg = messages[i];
        if (utils_1.isBrowser) {
            var style = transformStyles_1.transformToBrowserStyle(styles[i]);
            if (style)
                browserStyles.push(style);
        }
        output += _1.styler(msg, styles[i]);
        if (i < messages.length - 1) {
            output += ' ';
        }
    }
    console.log.apply(console, __spreadArrays([output], browserStyles));
}
exports.LogS = LogS;
/**Log a single message with an optional style, works in the browser and node. */
function LogSingle(message, style) {
    var output = _1.styler(message, style);
    if (utils_1.isBrowser) {
        console.log(output, transformStyles_1.transformToBrowserStyle(style) || '');
        return;
    }
    console.log(output);
}
exports.LogSingle = LogSingle;
