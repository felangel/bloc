"use strict";
exports.__esModule = true;
exports.convertScssOrCss = void 0;
var regex_1 = require("../regex/regex");
var logger_1 = require("../logger");
var utility_1 = require("../utility");
var format_property_1 = require("./format.property");
/** converts scss/css to sass. */
function convertScssOrCss(text, STATE) {
    var isMultiple = regex_1.isMoreThanOneClassOrId(text);
    var lastSelector = STATE.CONTEXT.convert.lastSelector;
    // if NOT interpolated class, id or partial
    if (!/[\t ]*[#.%]\{.*?}/.test(text)) {
        if (lastSelector && new RegExp('^.*' + regex_1.escapeRegExp(lastSelector)).test(text)) {
            /*istanbul ignore if */
            if (STATE.CONFIG.debug)
                logger_1.SetConvertData({ type: 'LAST SELECTOR', text: text });
            return {
                lastSelector: lastSelector,
                text: utility_1.replaceWithOffset(removeInvalidChars(text.replaceAll(lastSelector, '&')).trimEnd(), STATE.CONFIG.tabSize, STATE)
            };
        }
        else if (regex_1.isCssOneLiner(text)) {
            /*istanbul ignore if */
            if (STATE.CONFIG.debug)
                logger_1.SetConvertData({ type: 'ONE LINER', text: text });
            var split = text.split('{');
            var properties = split[1].split(';');
            // Set isProp to true so that it Sets the property space.
            STATE.LOCAL_CONTEXT.isProp = true;
            var selector = split[0].trim();
            return {
                lastSelector: selector,
                text: selector.concat('\n', properties
                    .map(function (v) {
                    return utility_1.replaceWithOffset(format_property_1.setPropertyValueSpaces(STATE, removeInvalidChars(v)).trim(), STATE.CONFIG.tabSize, STATE);
                })
                    .join('\n')).trimEnd()
            };
        }
        else if (regex_1.isCssPseudo(text) && !isMultiple) {
            /*istanbul ignore if */
            if (STATE.CONFIG.debug)
                logger_1.SetConvertData({ type: 'PSEUDO', text: text });
            return {
                lastSelector: lastSelector,
                text: removeInvalidChars(text).trimEnd()
            };
        }
        else if (regex_1.isCssSelector(text)) {
            /*istanbul ignore if */
            if (STATE.CONFIG.debug)
                logger_1.SetConvertData({ type: 'SELECTOR', text: text });
            lastSelector = removeInvalidChars(text).trimEnd();
            return { text: lastSelector, lastSelector: lastSelector };
        }
    }
    /*istanbul ignore if */
    if (STATE.CONFIG.debug)
        logger_1.SetConvertData({ type: 'DEFAULT', text: text });
    return { text: removeInvalidChars(text).trimEnd(), lastSelector: lastSelector };
}
exports.convertScssOrCss = convertScssOrCss;
function removeInvalidChars(text) {
    var newText = '';
    var isInQuotes = false;
    var isInComment = false;
    var isInInterpolation = false;
    var quoteChar = '';
    for (var i = 0; i < text.length; i++) {
        var char = text[i];
        if (!isInQuotes && char === '/' && text[i + 1] === '/') {
            isInComment = true;
        }
        else if (/['"]/.test(char)) {
            if (!isInQuotes || char === quoteChar) {
                isInQuotes = !isInQuotes;
                if (isInQuotes) {
                    quoteChar = char;
                }
            }
        }
        else if (/#/.test(char) && /{/.test(text[i + 1])) {
            isInInterpolation = true;
        }
        else if (isInInterpolation && /}/.test(text[i - 1])) {
            isInInterpolation = false;
        }
        if (!/[;\{\}]/.test(char) || isInQuotes || isInComment || isInInterpolation) {
            newText += char;
        }
    }
    return newText;
}
