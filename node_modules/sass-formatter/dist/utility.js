"use strict";
exports.__esModule = true;
exports.isKeyframePointAndSetIndentation = exports.convertLine = exports.replaceSpacesOrTabs = exports.getIndentationOffset = exports.replaceWithOffset = exports.getBlockHeaderOffset = void 0;
var regex_1 = require("./regex/regex");
/** returns the relative distance that the class or id should be at. */
function getBlockHeaderOffset(distance, tabSize, current, ignoreCurrent) {
    if (distance === 0) {
        return 0;
    }
    if (tabSize * Math.round(distance / tabSize - 0.1) > current && !ignoreCurrent) {
        return current - distance;
    }
    return tabSize * Math.round(distance / tabSize - 0.1) - distance;
}
exports.getBlockHeaderOffset = getBlockHeaderOffset;
/**
 * adds or removes whitespace based on the given offset, a positive value adds whitespace a negative value removes it.
 */
function replaceWithOffset(text, offset, STATE) {
    if (offset < 0) {
        text = text
            .replace(/\t/g, ' '.repeat(STATE.CONFIG.tabSize))
            .replace(new RegExp("^ {" + Math.abs(offset) + "}"), '');
        if (!STATE.CONFIG.insertSpaces) {
            text = replaceSpacesOrTabs(text, STATE, false);
        }
    }
    else {
        text = text.replace(/^/, STATE.CONFIG.insertSpaces ? ' '.repeat(offset) : '\t'.repeat(offset / STATE.CONFIG.tabSize));
    }
    return text;
}
exports.replaceWithOffset = replaceWithOffset;
/** returns the difference between the current indentation and the indentation of the given text. */
function getIndentationOffset(text, indentation, tabSize) {
    var distance = regex_1.getDistance(text, tabSize);
    return { offset: indentation - distance, distance: distance };
}
exports.getIndentationOffset = getIndentationOffset;
function isKeyframePoint(text, isAtKeyframe) {
    if (isAtKeyframe === false) {
        return false;
    }
    return /^[\t ]*\d+%/.test(text) || /^[\t ]*from[\t ]*$|^[\t ]*to[\t ]*$/.test(text);
}
function replaceSpacesOrTabs(text, STATE, insertSpaces) {
    if (insertSpaces !== undefined ? insertSpaces : STATE.CONFIG.insertSpaces) {
        return text.replace(/\t/g, ' '.repeat(STATE.CONFIG.tabSize));
    }
    else {
        return text.replace(new RegExp(' '.repeat(STATE.CONFIG.tabSize), 'g'), '\t');
    }
}
exports.replaceSpacesOrTabs = replaceSpacesOrTabs;
function convertLine(line, STATE) {
    return (STATE.CONFIG.convert &&
        regex_1.isScssOrCss(line.get()) &&
        !regex_1.isComment(line.get()));
}
exports.convertLine = convertLine;
function isKeyframePointAndSetIndentation(line, STATE) {
    var isAtKeyframesPoint = isKeyframePoint(line.get(), STATE.CONTEXT.keyframes.isIn);
    if (STATE.CONTEXT.keyframes.isIn && isAtKeyframesPoint) {
        STATE.CONTEXT.indentation = Math.max(0, STATE.CONTEXT.keyframes.indentation);
    }
    return isAtKeyframesPoint;
}
exports.isKeyframePointAndSetIndentation = isKeyframePointAndSetIndentation;
