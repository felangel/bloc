"use strict";
exports.__esModule = true;
exports.FormattingState = void 0;
var config_1 = require("./config");
var FormattingState = /** @class */ (function () {
    function FormattingState() {
        this.lines = [];
        /** Current line index. */
        this.currentLine = 0;
        this.LINE_ENDING = '\n';
        /** Formatting Result */
        this.RESULT = '';
        /** Context For Each Line. */
        this.LOCAL_CONTEXT = {
            isAdjacentSelector: false,
            isHtmlTag: false,
            isReset: false,
            indentation: {
                distance: 0,
                offset: 0
            },
            isAtExtend: false,
            isAnd: false,
            isClassOrIdSelector: false,
            isIf: false,
            isElse: false,
            isAtKeyframes: false,
            isAtKeyframesPoint: false,
            isProp: false,
            isInterpolatedProp: false,
            isInclude: false,
            isVariable: false,
            isImport: false,
            isNestPropHead: false
        };
        this.CONTEXT = {
            "if": {
                isIn: false,
                indentation: 0
            },
            blockCommentDistance: 0,
            wasLastHeaderIncludeMixin: false,
            wasLastHeaderNestedProp: false,
            isFirstLine: true,
            isLastLine: false,
            allowSpace: false,
            isInBlockComment: false,
            ignoreLine: false,
            lastSelectorIndentation: 0,
            wasLastLineSelector: false,
            convert: {
                lastSelector: '',
                wasLastLineCss: false
            },
            keyframes: {
                isIn: false,
                indentation: 0
            },
            indentation: 0,
            firstCommaHeader: { exists: false, distance: 0 }
        };
        this.CONFIG = config_1.defaultSassFormatterConfig;
    }
    FormattingState.prototype.setLocalContext = function (context) {
        this.LOCAL_CONTEXT = context;
    };
    return FormattingState;
}());
exports.FormattingState = FormattingState;
