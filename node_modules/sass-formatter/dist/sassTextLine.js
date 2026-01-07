"use strict";
exports.__esModule = true;
exports.SassTextLine = void 0;
var regex_1 = require("./regex/regex");
var SassTextLine = /** @class */ (function () {
    function SassTextLine(text) {
        this.text = text;
        this.isEmptyOrWhitespace = regex_1.isEmptyOrWhitespace(text);
    }
    /**Sets the text of the line. */
    SassTextLine.prototype.set = function (text) {
        this.text = text;
    };
    /**Gets the text of the line. */
    SassTextLine.prototype.get = function () {
        return this.text;
    };
    return SassTextLine;
}());
exports.SassTextLine = SassTextLine;
