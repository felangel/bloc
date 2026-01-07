export declare function escapeRegExp(text: string): string;
/** Check whether text is a variable: `/^[\t ]*(\$|--)\S+[\t ]*:.*/
export declare function isVar(text: string): boolean;
/** Check whether text @import: `/^[\t ]*@import/` */
export declare function isAtImport(text: string): boolean;
/** Check whether text is a \*: `/^[\t ]*?\*\/` */
export declare function isStar(text: string): boolean;
/** Check whether text is a css selector: `/^[\t ]*[{}]?[\t ]*[#\.%@=]/` */
export declare function isCssSelector(text: string): boolean;
/**Check whether text is class, id or placeholder: `/^[\t ]*[#\.%]/` */
export declare function isClassOrId(text: string): boolean;
/**Check whether text starts with one of [>\~]: `/^[\t ]*[>~]/` */
export declare function isSelectorOperator(text: string): boolean;
/**`/^[\t ]*\+[\t ]+/` */
export declare function isAdjacentSelector(text: string): boolean;
/**Check whether text is class, id or placeholder: `/^[\t ]*\r?\n?$/` */
export declare function isEmptyOrWhitespace(text: string): boolean;
/** Check whether text is a property: `^[\t ]*[\w\-]+[\t ]*:` */
export declare function isProperty(text: string): boolean;
/** Check whether text starts with &: `/^[\t ]*&/` */
export declare function isAnd(text: string): boolean;
/** Check whether text is a extend: `/^[\t ]*@extend/` */
export declare function isAtExtend(text: string): boolean;
/** Check whether text is include mixin statement */
export declare function isInclude(text: string): boolean;
/** Check whether text is a @keyframes: `/^[\t ]*@keyframes/` */
export declare function isKeyframes(text: string): boolean;
/** Check whether text is a Pseudo selector: `/^[\t ]*\\?::?/`. */
export declare function isPseudo(text: string): boolean;
/** Check whether text is bracket selector: `/^[\t ]*\[[\w=\-*'' ]*\]/`*/
export declare function isBracketSelector(text: string): boolean;
/** Check whether text starts with an html tag. */
export declare function isHtmlTag(text: string): boolean;
/** Check whether text starts with a self closing html tag. */
export declare function isVoidHtmlTag(text: string): boolean;
/** Check whether text starts with //R: `/^[\t ]*\/?\/\/ *R *$/` */
export declare function isReset(text: string): boolean;
/** Check whether text starts with //I: `/^[\t ]*\/?\/\/ *I *$/` */
export declare function isIgnore(text: string): boolean;
/** Check whether text starts with //S: `/^[\t ]*\/?\/\/ *S *$/` */
export declare function isSassSpace(text: string): boolean;
/** Returns true if the string has brackets or semicolons at the end, comments get ignored. */
export declare function isScssOrCss(text: string): boolean;
/** `/^[\t ]*[&.#%].*:/` */
export declare function isCssPseudo(text: string): boolean;
/** `/^[\t ]*[&.#%][\w-]*(?!#)[\t ]*\{.*[;\}][\t ]*$/` */
export declare function isCssOneLiner(text: string): boolean;
/** `/^[\t ]*::?[\w\-]+\(.*\)/` */
/** `/^[\t ]*(\/\/|\/\*)/` */
export declare function isComment(text: string): boolean;
/** `/^[\t ]*(\/\*)/` */
export declare function isBlockCommentStart(text: string): boolean;
/** `/[\t ]*(\*\/)/` */
export declare function isBlockCommentEnd(text: string): boolean;
/** `/^[\t ]*[\.#%].* ?, *[\.#%].*\/` */
export declare function isMoreThanOneClassOrId(text: string): boolean;
/** `/^[\t ]*[}{]+[\t }{]*$/` */
export declare function isBracketOrWhitespace(text: string): boolean;
/** `/[\t ]*@forward|[\t ]*@use/` */
export declare function isAtForwardOrAtUse(text: string): boolean;
export declare function isInterpolatedProperty(text: string): boolean;
export declare function hasPropertyValueSpace(text: string): boolean;
/** returns the distance between the beginning and the first char. */
export declare function getDistance(text: string, tabSize: number): number;
