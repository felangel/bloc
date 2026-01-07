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
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
exports.__esModule = true;
exports.SassFormatter = exports.defaultSassFormatterConfig = void 0;
var format_atForwardOrAtUse_1 = require("./formatters/format.atForwardOrAtUse");
var format_blockComment_1 = require("./formatters/format.blockComment");
var format_header_1 = require("./formatters/format.header");
var format_property_1 = require("./formatters/format.property");
var logger_1 = require("./logger");
var regex_1 = require("./regex/regex");
var sassTextLine_1 = require("./sassTextLine");
var state_1 = require("./state");
var utility_1 = require("./utility");
var config_1 = require("./config");
__createBinding(exports, config_1, "defaultSassFormatterConfig");
var SassFormatter = /** @class */ (function () {
    function SassFormatter() {
    }
    SassFormatter.Format = function (text, config) {
        var STATE = new state_1.FormattingState();
        STATE.lines = text.split(/\r?\n/);
        STATE.CONFIG = __assign(__assign({}, STATE.CONFIG), config);
        STATE.LINE_ENDING = STATE.CONFIG.lineEnding === 'LF' ? '\n' : '\r\n';
        for (var i = 0; i < STATE.lines.length; i++) {
            STATE.currentLine = i;
            this.formatLine(new sassTextLine_1.SassTextLine(STATE.lines[i]), STATE);
        }
        if (!STATE.RESULT.endsWith(STATE.LINE_ENDING)) {
            this.addNewLine(STATE);
        }
        if (STATE.CONFIG.debug) {
            logger_1.LogDebugResult(STATE.RESULT);
            logger_1.ResetDebugLog();
        }
        return STATE.RESULT;
    };
    SassFormatter.formatLine = function (line, STATE) {
        if (regex_1.isBlockCommentStart(line.get())) {
            STATE.CONTEXT.isInBlockComment = true;
            STATE.CONTEXT.blockCommentDistance = regex_1.getDistance(line.get(), STATE.CONFIG.tabSize);
        }
        else if (!line.isEmptyOrWhitespace &&
            STATE.CONTEXT.isInBlockComment &&
            STATE.CONTEXT.blockCommentDistance >= regex_1.getDistance(line.get(), STATE.CONFIG.tabSize)) {
            STATE.CONTEXT.isInBlockComment = false;
            STATE.CONTEXT.blockCommentDistance = 0;
        }
        if (STATE.CONTEXT.ignoreLine) {
            STATE.CONTEXT.ignoreLine = false;
            this.addNewLine(STATE);
            STATE.RESULT += line.get();
            logger_1.PushDebugInfo({
                title: 'IGNORED',
                lineNumber: STATE.currentLine,
                oldLineText: line.get(),
                debug: STATE.CONFIG.debug,
                newLineText: 'NULL'
            });
        }
        else if (STATE.CONTEXT.isInBlockComment) {
            this.handleCommentBlock(STATE, line);
        }
        else {
            if (regex_1.isIgnore(line.get())) {
                STATE.CONTEXT.ignoreLine = true;
                this.addNewLine(STATE);
                STATE.RESULT += line.get();
                logger_1.PushDebugInfo({
                    title: 'IGNORE',
                    lineNumber: STATE.currentLine,
                    oldLineText: line.get(),
                    debug: STATE.CONFIG.debug,
                    newLineText: 'NULL'
                });
            }
            else {
                if (regex_1.isSassSpace(line.get())) {
                    STATE.CONTEXT.allowSpace = true;
                }
                // ####### Empty Line #######
                if (line.isEmptyOrWhitespace ||
                    (STATE.CONFIG.convert ? regex_1.isBracketOrWhitespace(line.get()) : false)) {
                    this.handleEmptyLine(STATE, line);
                }
                else {
                    STATE.setLocalContext({
                        isAtKeyframesPoint: utility_1.isKeyframePointAndSetIndentation(line, STATE),
                        indentation: utility_1.getIndentationOffset(line.get(), STATE.CONTEXT.indentation, STATE.CONFIG.tabSize),
                        isIf: /[\t ]*@if/i.test(line.get()),
                        isElse: /[\t ]*@else/i.test(line.get()),
                        isAtKeyframes: regex_1.isKeyframes(line.get()),
                        isReset: regex_1.isReset(line.get()),
                        isAnd: regex_1.isAnd(line.get()),
                        isProp: regex_1.isProperty(line.get()),
                        isAdjacentSelector: regex_1.isAdjacentSelector(line.get()),
                        isHtmlTag: regex_1.isHtmlTag(line.get()),
                        isClassOrIdSelector: regex_1.isClassOrId(line.get()),
                        isAtExtend: regex_1.isAtExtend(line.get()),
                        isInterpolatedProp: regex_1.isInterpolatedProperty(line.get()),
                        isInclude: regex_1.isInclude(line.get()),
                        isVariable: regex_1.isVar(line.get()),
                        isImport: regex_1.isAtImport(line.get()),
                        isNestPropHead: /^[\t ]* \S*[\t ]*:[\t ]*\{?$/.test(line.get())
                    });
                    if (STATE.CONFIG.debug) {
                        if (/\/\/[\t ]*info[\t ]*$/.test(line.get())) {
                            logger_1.SetDebugLOCAL_CONTEXT(STATE.LOCAL_CONTEXT);
                        }
                    }
                    // ####### Is @forward or @use #######
                    if (regex_1.isAtForwardOrAtUse(line.get())) {
                        this.addNewLine(STATE);
                        STATE.RESULT += format_atForwardOrAtUse_1.FormatAtForwardOrAtUse(line, STATE);
                    }
                    // ####### Block Header #######
                    else if (this.isBlockHeader(line, STATE)) {
                        this.addNewLine(STATE);
                        STATE.RESULT += format_header_1.FormatBlockHeader(line, STATE);
                    }
                    // ####### Properties or Vars #######
                    else if (this.isProperty(STATE)) {
                        STATE.CONTEXT.firstCommaHeader.exists = false;
                        this.addNewLine(STATE);
                        STATE.RESULT += format_property_1.FormatProperty(line, STATE);
                    }
                    else {
                        logger_1.PushDebugInfo({
                            title: 'NO CHANGE',
                            lineNumber: STATE.currentLine,
                            oldLineText: line.get(),
                            debug: STATE.CONFIG.debug,
                            newLineText: 'NULL'
                        });
                        this.addNewLine(STATE);
                        STATE.RESULT += line.get();
                    }
                    // set CONTEXT Variables
                    STATE.CONTEXT.wasLastLineSelector =
                        STATE.LOCAL_CONTEXT.isClassOrIdSelector ||
                            STATE.LOCAL_CONTEXT.isAdjacentSelector ||
                            STATE.LOCAL_CONTEXT.isHtmlTag;
                }
            }
        }
    };
    SassFormatter.handleCommentBlock = function (STATE, line) {
        this.addNewLine(STATE);
        var edit = line.isEmptyOrWhitespace ? "" : format_blockComment_1.FormatHandleBlockComment(line.get(), STATE);
        STATE.RESULT += edit;
        if (regex_1.isBlockCommentEnd(line.get())) {
            STATE.CONTEXT.isInBlockComment = false;
        }
        logger_1.PushDebugInfo({
            title: 'COMMENT BLOCK',
            lineNumber: STATE.currentLine,
            oldLineText: STATE.lines[STATE.currentLine],
            newLineText: edit,
            debug: STATE.CONFIG.debug
        });
    };
    SassFormatter.handleEmptyLine = function (STATE, line) {
        STATE.CONTEXT.firstCommaHeader.exists = false;
        var pass = true; // its not useless, trust me.
        /*istanbul ignore else */
        if (STATE.CONFIG.deleteEmptyRows && !STATE.CONTEXT.isLastLine) {
            var nextLine = new sassTextLine_1.SassTextLine(STATE.lines[STATE.currentLine + 1]);
            var compact = !regex_1.isProperty(nextLine.get());
            var nextLineWillBeDeleted = STATE.CONFIG.convert
                ? regex_1.isBracketOrWhitespace(nextLine.get())
                : false;
            if ((compact && !STATE.CONTEXT.allowSpace && nextLine.isEmptyOrWhitespace) ||
                (compact && !STATE.CONTEXT.allowSpace && nextLineWillBeDeleted)) {
                logger_1.PushDebugInfo({
                    title: 'EMPTY LINE: DELETE',
                    nextLine: nextLine,
                    lineNumber: STATE.currentLine,
                    oldLineText: STATE.lines[STATE.currentLine],
                    newLineText: 'DELETED',
                    debug: STATE.CONFIG.debug
                });
                pass = false;
            }
        }
        if (line.get().length > 0 && pass) {
            logger_1.PushDebugInfo({
                title: 'EMPTY LINE: WHITESPACE',
                lineNumber: STATE.currentLine,
                oldLineText: STATE.lines[STATE.currentLine],
                newLineText: 'NEWLINE',
                debug: STATE.CONFIG.debug
            });
            this.addNewLine(STATE);
        }
        else if (pass) {
            logger_1.PushDebugInfo({
                title: 'EMPTY LINE',
                lineNumber: STATE.currentLine,
                oldLineText: STATE.lines[STATE.currentLine],
                newLineText: 'NEWLINE',
                debug: STATE.CONFIG.debug
            });
            this.addNewLine(STATE);
        }
    };
    SassFormatter.isBlockHeader = function (line, STATE) {
        return (!STATE.LOCAL_CONTEXT.isInterpolatedProp &&
            !STATE.LOCAL_CONTEXT.isAtExtend &&
            !STATE.LOCAL_CONTEXT.isImport &&
            (STATE.LOCAL_CONTEXT.isAdjacentSelector ||
                STATE.LOCAL_CONTEXT.isReset ||
                STATE.LOCAL_CONTEXT.isAnd ||
                (STATE.LOCAL_CONTEXT.isHtmlTag && !/^[\t ]*style[\t ]*:/.test(line.get())) ||
                STATE.LOCAL_CONTEXT.isInclude ||
                STATE.LOCAL_CONTEXT.isNestPropHead ||
                regex_1.isPseudo(line.get()) ||
                regex_1.isSelectorOperator(line.get()) ||
                regex_1.isStar(line.get()) ||
                regex_1.isBracketSelector(line.get()) ||
                regex_1.isCssSelector(line.get())) // adds all lines that start with [@.#%=]
        );
    };
    SassFormatter.isProperty = function (STATE) {
        return (STATE.LOCAL_CONTEXT.isImport ||
            STATE.LOCAL_CONTEXT.isAtExtend ||
            STATE.LOCAL_CONTEXT.isVariable ||
            STATE.LOCAL_CONTEXT.isInterpolatedProp ||
            STATE.LOCAL_CONTEXT.isProp ||
            STATE.LOCAL_CONTEXT.isAtKeyframesPoint);
    };
    /** Adds new Line If not first line. */
    SassFormatter.addNewLine = function (STATE) {
        if (!STATE.CONTEXT.isFirstLine) {
            STATE.RESULT += STATE.LINE_ENDING;
        }
        else {
            STATE.CONTEXT.isFirstLine = false;
        }
    };
    return SassFormatter;
}());
exports.SassFormatter = SassFormatter;
