"use strict";
exports.__esModule = true;
exports.PushDebugInfo = exports.SetConvertData = exports.SetDebugLOCAL_CONTEXT = exports.ResetDebugLog = exports.LogDebugResult = void 0;
var suf_log_1 = require("suf-log");
suf_log_1.SetEnvironment('node');
var colon = suf_log_1.styler(':', '#777');
// const quote = styler('"', '#f64');
var pipe = suf_log_1.styler('|', '#f64');
var TEXT = function (text) { return suf_log_1.styler(text, '#eee'); };
var NUMBER = function (number) { return suf_log_1.styler(number.toString(), '#f03'); };
var BOOL = function (bool) { return suf_log_1.styler(bool.toString(), bool ? '#4f6' : '#f03'); };
function LogDebugResult(result) {
    var data = StoreLog.logs;
    var out = suf_log_1.styler('FORMAT', { "font-weight": 'bold', color: '#0af' });
    for (var i = 0; i < data.length; i++) {
        out += '\n';
        out += InfoLogHelper(data[i]);
    }
    out += "\n" + pipe + suf_log_1.styler(replaceWhitespace(result.replace(/\n/g, '|\n|')), '#c76') + pipe;
    console.log(out);
}
exports.LogDebugResult = LogDebugResult;
function ResetDebugLog() {
    StoreLog.reset();
}
exports.ResetDebugLog = ResetDebugLog;
var StoreLog = /** @class */ (function () {
    function StoreLog() {
    }
    StoreLog.resetTemp = function () {
        this.tempConvertData = undefined;
        this.tempLOCAL_CONTEXT = undefined;
    };
    StoreLog.reset = function () {
        this.resetTemp();
        this.logs = [];
    };
    StoreLog.logs = [];
    return StoreLog;
}());
function SetDebugLOCAL_CONTEXT(data) {
    StoreLog.tempLOCAL_CONTEXT = data;
}
exports.SetDebugLOCAL_CONTEXT = SetDebugLOCAL_CONTEXT;
function SetConvertData(data) {
    StoreLog.tempConvertData = data;
}
exports.SetConvertData = SetConvertData;
function PushDebugInfo(info) {
    if (info.debug) {
        StoreLog.logs.push({
            info: info,
            convertData: StoreLog.tempConvertData,
            LOCAL_CONTEXT: StoreLog.tempLOCAL_CONTEXT
        });
    }
    StoreLog.resetTemp();
}
exports.PushDebugInfo = PushDebugInfo;
function InfoLogHelper(data) {
    var convertData = data.convertData, info = data.info, LOCAL_CONTEXT = data.LOCAL_CONTEXT;
    var notProvided = null;
    var title = suf_log_1.styler(info.title, '#cc0');
    var lineNumber = "" + TEXT('Line Number') + colon + " " + NUMBER(info.lineNumber);
    var offset = info.offset !== undefined ? "" + TEXT('Offset') + colon + " " + NUMBER(info.offset) : '';
    var originalOffset = info.originalOffset !== undefined ? "" + TEXT('Original Offset') + colon + " " + NUMBER(info.originalOffset) : '';
    var nextLine = info.nextLine !== undefined
        ? JSON.stringify(info.nextLine)
            .replace(/[{}]/g, '')
            .replace(/:/g, ': ')
            .replace(/,/g, ', ')
            .replace(/".*?"/g, function (s) {
            return suf_log_1.styler(s, '#c76');
        })
        : notProvided;
    var replace = info.replaceSpaceOrTabs !== undefined ? BOOL(info.replaceSpaceOrTabs) : notProvided;
    var CONVERT = convertData
        ? "\n      " + TEXT('Convert') + "        " + colon + " " + suf_log_1.styler(convertData.type, '#f64')
        : '';
    var newText = info.newLineText ? "\n      " + TEXT('New') + "            " + colon + " " + suf_log_1.styler(replaceWhitespace(info.newLineText.replace(/\n/g, '\\n')), '#0af') : '';
    switch (info.newLineText) {
        case 'DELETED':
            return " " + title + " " + lineNumber + " " + TEXT('Next Line') + colon + " " + nextLine;
        case 'NEWLINE':
        case 'NULL':
            return " " + title + " " + lineNumber;
        default:
            var data_1 = '';
            data_1 +=
                nextLine !== null ? "\n      " + TEXT('Next Line') + "      " + colon + " " + nextLine : '';
            data_1 +=
                replace !== null ? "\n      " + TEXT('Replace') + "        " + colon + " " + replace : '';
            if (LOCAL_CONTEXT) {
                data_1 += "\n " + suf_log_1.styler('LOCAL_CONTEXT', '#f64') + " " + suf_log_1.styler('{', '#777');
                for (var key in LOCAL_CONTEXT) {
                    if (Object.prototype.hasOwnProperty.call(LOCAL_CONTEXT, key)) {
                        var val = LOCAL_CONTEXT[key];
                        data_1 += "\n    " + suf_log_1.styler(key, '#777') + colon + " " + parseValue(val);
                    }
                }
                data_1 += suf_log_1.styler('\n }', '#777');
            }
            return " " + title + " " + lineNumber + " " + offset + " " + originalOffset + "\n      " + TEXT('Old') + "            " + colon + " " + suf_log_1.styler(replaceWhitespace(info.oldLineText), '#d75') + newText + CONVERT + data_1;
    }
}
function replaceWhitespace(text) {
    return text.replace(/ /g, '·').replace(/\t/g, '⟶');
}
function parseValue(val) {
    var type = typeof val;
    if (type === 'boolean') {
        return BOOL(val);
    }
    else if (type === 'string') {
        return suf_log_1.styler(val, '#f64');
    }
    else if (type === 'object') {
        return suf_log_1.styler(JSON.stringify(val), '#0af');
    }
    return val;
}
