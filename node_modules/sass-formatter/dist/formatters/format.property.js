"use strict";
exports.__esModule = true;
exports.setPropertyValueSpaces = exports.FormatProperty = void 0;
var logger_1 = require("../logger");
var regex_1 = require("../regex/regex");
var utility_1 = require("../utility");
var format_convert_1 = require("./format.convert");
function FormatProperty(line, STATE) {
    var convert = false;
    var replaceSpaceOrTabs = false;
    var edit = line.get();
    var isComment = regex_1.isComment(line.get());
    line.set(setPropertyValueSpaces(STATE, line.get()));
    if (utility_1.convertLine(line, STATE)) {
        var convertRes = format_convert_1.convertScssOrCss(line.get(), STATE);
        line.set(convertRes.text);
        convert = true;
    }
    // Set Context Vars
    STATE.CONTEXT.convert.wasLastLineCss = convert;
    var move = STATE.LOCAL_CONTEXT.indentation.offset !== 0 && !isComment;
    if (!move && canReplaceSpacesOrTabs(STATE, line.get())) {
        line.set(utility_1.replaceSpacesOrTabs(line.get(), STATE).trimRight());
        replaceSpaceOrTabs = true;
    }
    // Return
    if (move) {
        var offset = STATE.LOCAL_CONTEXT.indentation.offset;
        var distance = STATE.LOCAL_CONTEXT.indentation.distance;
        if (STATE.CONTEXT.wasLastHeaderIncludeMixin || STATE.CONTEXT.wasLastHeaderNestedProp) {
            if (distance >= STATE.CONTEXT.indentation - STATE.CONFIG.tabSize) {
                offset = utility_1.getBlockHeaderOffset(distance, STATE.CONFIG.tabSize, STATE.CONTEXT.indentation, false);
            }
            else {
                offset = (STATE.CONTEXT.indentation - STATE.CONFIG.tabSize) - distance;
                STATE.CONTEXT.wasLastHeaderIncludeMixin = false;
                STATE.CONTEXT.wasLastHeaderNestedProp = false;
                STATE.CONTEXT.indentation = STATE.CONTEXT.indentation - STATE.CONFIG.tabSize;
            }
        }
        else if (STATE.LOCAL_CONTEXT.isVariable || STATE.LOCAL_CONTEXT.isImport) {
            offset = utility_1.getBlockHeaderOffset(distance, STATE.CONFIG.tabSize, STATE.CONTEXT.indentation, false);
        }
        edit = utility_1.replaceWithOffset(line.get(), offset, STATE).trimRight();
        logger_1.PushDebugInfo({
            title: 'PROPERTY: MOVE',
            lineNumber: STATE.currentLine,
            oldLineText: STATE.lines[STATE.currentLine],
            newLineText: edit,
            debug: STATE.CONFIG.debug,
            offset: offset,
            originalOffset: STATE.LOCAL_CONTEXT.indentation.offset,
            replaceSpaceOrTabs: replaceSpaceOrTabs
        });
    }
    else {
        edit = line.get().trimRight();
        logger_1.PushDebugInfo({
            title: 'PROPERTY: DEFAULT',
            lineNumber: STATE.currentLine,
            oldLineText: STATE.lines[STATE.currentLine],
            newLineText: edit,
            debug: STATE.CONFIG.debug,
            replaceSpaceOrTabs: replaceSpaceOrTabs
        });
    }
    if (STATE.CONTEXT.keyframes.isIn && STATE.LOCAL_CONTEXT.isAtKeyframesPoint) {
        STATE.CONTEXT.indentation = Math.max(0, STATE.CONTEXT.indentation + STATE.CONFIG.tabSize);
    }
    return edit;
}
exports.FormatProperty = FormatProperty;
function canReplaceSpacesOrTabs(STATE, text) {
    return STATE.CONFIG.insertSpaces
        ? /\t/g.test(text)
        : new RegExp(' '.repeat(STATE.CONFIG.tabSize), 'g').test(text);
}
function setPropertyValueSpaces(STATE, text) {
    if (text &&
        (!STATE.LOCAL_CONTEXT.isHtmlTag &&
            (STATE.LOCAL_CONTEXT.isProp || STATE.LOCAL_CONTEXT.isInterpolatedProp || STATE.LOCAL_CONTEXT.isVariable) &&
            STATE.CONFIG.setPropertySpace)) {
        var newPropValue = '';
        var _a = text.split(/:(.*)/), propName = _a[0], propValue = _a[1];
        var wasLastCharSpace = true;
        for (var i = 0; i < propValue.length; i++) {
            var char = propValue[i];
            switch (char) {
                case ' ':
                    if (!wasLastCharSpace) {
                        newPropValue += char;
                        wasLastCharSpace = true;
                    }
                    break;
                case '.':
                    wasLastCharSpace = true;
                    newPropValue += char;
                    break;
                default:
                    wasLastCharSpace = false;
                    newPropValue += char;
                    break;
            }
        }
        return propName.trimEnd() + ":" + (propValue ? ' ' + newPropValue : '');
    }
    return text;
}
exports.setPropertyValueSpaces = setPropertyValueSpaces;
