"use strict";
exports.__esModule = true;
exports.getDistance = exports.hasPropertyValueSpace = exports.isInterpolatedProperty = exports.isAtForwardOrAtUse = exports.isBracketOrWhitespace = exports.isMoreThanOneClassOrId = exports.isBlockCommentEnd = exports.isBlockCommentStart = exports.isComment = exports.isCssOneLiner = exports.isCssPseudo = exports.isScssOrCss = exports.isSassSpace = exports.isIgnore = exports.isReset = exports.isVoidHtmlTag = exports.isHtmlTag = exports.isBracketSelector = exports.isPseudo = exports.isKeyframes = exports.isInclude = exports.isAtExtend = exports.isAnd = exports.isProperty = exports.isEmptyOrWhitespace = exports.isAdjacentSelector = exports.isSelectorOperator = exports.isClassOrId = exports.isCssSelector = exports.isStar = exports.isAtImport = exports.isVar = exports.escapeRegExp = void 0;
function escapeRegExp(text) {
    return text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&');
}
exports.escapeRegExp = escapeRegExp;
/** Check whether text is a variable: `/^[\t ]*(\$|--)\S+[\t ]*:.*/
function isVar(text) {
    return /^[\t ]*(\$|--)\S+[\t ]*:.*/.test(text);
}
exports.isVar = isVar;
/** Check whether text @import: `/^[\t ]*@import/` */
function isAtImport(text) {
    return /^[\t ]*@import/.test(text);
}
exports.isAtImport = isAtImport;
/** Check whether text is a \*: `/^[\t ]*?\*\/` */
function isStar(text) {
    return /^[\t ]*?\*/.test(text);
}
exports.isStar = isStar;
/** Check whether text is a css selector: `/^[\t ]*[{}]?[\t ]*[#\.%@=]/` */
function isCssSelector(text) {
    return /^[\t ]*[{}]?[\t ]*[#\.%@=]/.test(text);
}
exports.isCssSelector = isCssSelector;
/**Check whether text is class, id or placeholder: `/^[\t ]*[#\.%]/` */
function isClassOrId(text) {
    return /^[\t ]*[#\.%]/.test(text);
}
exports.isClassOrId = isClassOrId;
/**Check whether text starts with one of [>\~]: `/^[\t ]*[>~]/` */
function isSelectorOperator(text) {
    return /^[\t ]*[>~]/.test(text);
}
exports.isSelectorOperator = isSelectorOperator;
/**`/^[\t ]*\+[\t ]+/` */
function isAdjacentSelector(text) {
    return /^[\t ]*\+[\t ]+/.test(text);
}
exports.isAdjacentSelector = isAdjacentSelector;
/**Check whether text is class, id or placeholder: `/^[\t ]*\r?\n?$/` */
function isEmptyOrWhitespace(text) {
    return /^[\t ]*\r?\n?$/.test(text);
}
exports.isEmptyOrWhitespace = isEmptyOrWhitespace;
/** Check whether text is a property: `^[\t ]*[\w\-]+[\t ]*:` */
function isProperty(text) {
    // if (empty) {
    //   return !/^[\t ]*[\w\-]+ *: *\S+/.test(text);
    // }
    return /^[\t ]*[\w\-]+[\t ]*:/.test(text);
}
exports.isProperty = isProperty;
/** Check whether text starts with &: `/^[\t ]*&/` */
function isAnd(text) {
    return /^[\t ]*&/.test(text);
}
exports.isAnd = isAnd;
/** Check whether text is a extend: `/^[\t ]*@extend/` */
function isAtExtend(text) {
    return /^[\t ]*@extend/.test(text);
}
exports.isAtExtend = isAtExtend;
/** Check whether text is include mixin statement */
function isInclude(text) {
    return /^[\t ]*(@include|\+\w)/.test(text);
}
exports.isInclude = isInclude;
/** Check whether text is a @keyframes: `/^[\t ]*@keyframes/` */
function isKeyframes(text) {
    return /^[\t ]*@keyframes/.test(text);
}
exports.isKeyframes = isKeyframes;
/** Check whether text is a Pseudo selector: `/^[\t ]*\\?::?/`. */
function isPseudo(text) {
    return /^[\t ]*\\?::?/.test(text);
}
exports.isPseudo = isPseudo;
/** Check whether text is bracket selector: `/^[\t ]*\[[\w=\-*'' ]*\]/`*/
function isBracketSelector(text) {
    return /^[\t ]*\[[\w=\-*'' ]*\]/.test(text);
}
exports.isBracketSelector = isBracketSelector;
/** Check whether text starts with an html tag. */
function isHtmlTag(text) {
    return /^[\t ]*(a|abbr|address|area|article|aside|audio|b|base|bdi|bdo|blockquote|body|br|button|canvas|caption|cite|code|col|colgroup|data|datalist|dd|del|details|dfn|dialog|div|dl|dt|em|embed|fieldset|figcaption|figure|footer|form|h1|h2|h3|h4|h5|h6|head|header|hgroup|hr|html|i|iframe|img|picture|input|ins|kbd|keygen|label|legend|li|link|main|map|mark|menu|menuitem|meta|meter|nav|noscript|object|ol|optgroup|option|output|p|param|pre|progress|q|rb|rp|rt|rtc|ruby|s|samp|script|section|select|small|source|span|strong|style|sub|summary|sup|svg|table|tbody|td|template|textarea|tfoot|th|thead|time|title|tr|track|u|ul|var|video|wbr|path|circle|ellipse|line|polygon|polyline|rect|text|slot|h[1-6]?|([a-z]+\-[a-z]+[\t ]*(?!:)))((:|::|,|\.|#|\[)[\^:$#{}()\w\-\[\]='",\.# \t+\/>]*)?[ \t]*[&]?[ \t]*{?$/.test(text);
}
exports.isHtmlTag = isHtmlTag;
/** Check whether text starts with a self closing html tag. */
function isVoidHtmlTag(text) {
    return /^[\t ]*(area|base|br|col|embed|hr|img|input|link|meta|param|source|track|wbr|command|keygen|menuitem|path)((:|::|,|\.|#|\[)[:$#{}()\w\-\[\]='",\.# ]*)?$/.test(text);
}
exports.isVoidHtmlTag = isVoidHtmlTag;
/** Check whether text starts with //R: `/^[\t ]*\/?\/\/ *R *$/` */
function isReset(text) {
    return /^[\t ]*\/?\/\/ *R *$/.test(text);
}
exports.isReset = isReset;
/** Check whether text starts with //I: `/^[\t ]*\/?\/\/ *I *$/` */
function isIgnore(text) {
    return /^[\t ]*\/?\/\/ *I *$/.test(text);
}
exports.isIgnore = isIgnore;
/** Check whether text starts with //S: `/^[\t ]*\/?\/\/ *S *$/` */
function isSassSpace(text) {
    return /^[\t ]*\/?\/\/ *S *$/.test(text);
}
exports.isSassSpace = isSassSpace;
/** Returns true if the string has brackets or semicolons at the end, comments get ignored. */
function isScssOrCss(text) {
    // Check if has brackets at the end and ignore comments.
    return /[;\{\}][\t ]*(\/\/.*)?$/.test(text);
}
exports.isScssOrCss = isScssOrCss;
/** `/^[\t ]*[&.#%].*:/` */
function isCssPseudo(text) {
    return /^[\t ]*[&.#%].*:/.test(text);
}
exports.isCssPseudo = isCssPseudo;
/** `/^[\t ]*[&.#%][\w-]*(?!#)[\t ]*\{.*[;\}][\t ]*$/` */
function isCssOneLiner(text) {
    return /^[\t ]*[&.#%][\w-]*(?!#)[\t ]*\{.*[;\}][\t ]*$/.test(text);
}
exports.isCssOneLiner = isCssOneLiner;
/** `/^[\t ]*::?[\w\-]+\(.*\)/` */
// export function isPseudoWithParenthesis(text: string) {
//   return /^[\t ]*::?[\w\-]+\(.*\)/.test(text);
// }
/** `/^[\t ]*(\/\/|\/\*)/` */
function isComment(text) {
    return /^[\t ]*(\/\/|\/\*)/.test(text);
}
exports.isComment = isComment;
/** `/^[\t ]*(\/\*)/` */
function isBlockCommentStart(text) {
    return /^[\t ]*(\/\*)/.test(text);
}
exports.isBlockCommentStart = isBlockCommentStart;
/** `/[\t ]*(\*\/)/` */
function isBlockCommentEnd(text) {
    return /[\t ]*(\*\/)/.test(text);
}
exports.isBlockCommentEnd = isBlockCommentEnd;
/** `/^[\t ]*[\.#%].* ?, *[\.#%].*\/` */
function isMoreThanOneClassOrId(text) {
    return /^[\t ]*[\.#%].* ?, *[\.#%].*/.test(text);
}
exports.isMoreThanOneClassOrId = isMoreThanOneClassOrId;
/** `/^[\t ]*[}{]+[\t }{]*$/` */
function isBracketOrWhitespace(text) {
    return /^[\t ]*[}{]+[\t }{]*$/.test(text);
}
exports.isBracketOrWhitespace = isBracketOrWhitespace;
/** `/[\t ]*@forward|[\t ]*@use/` */
function isAtForwardOrAtUse(text) {
    return /[\t ]*@forward|[\t ]*@use/.test(text);
}
exports.isAtForwardOrAtUse = isAtForwardOrAtUse;
function isInterpolatedProperty(text) {
    return /^[\t ]*[\w-]*#\{.*?\}[\w-]*:(?!:)/.test(text);
}
exports.isInterpolatedProperty = isInterpolatedProperty;
function hasPropertyValueSpace(text) {
    return /^[\t ]*([\w ]+|[\w ]*#\{.*?\}[\w ]*): [^ ]/.test(text);
}
exports.hasPropertyValueSpace = hasPropertyValueSpace;
/** returns the distance between the beginning and the first char. */
function getDistance(text, tabSize) {
    var count = 0;
    for (var i = 0; i < text.length; i++) {
        var char = text[i];
        if (char !== ' ' && char !== '\t') {
            break;
        }
        if (char === '\t') {
            count += tabSize;
        }
        else {
            count++;
        }
    }
    return count;
}
exports.getDistance = getDistance;
