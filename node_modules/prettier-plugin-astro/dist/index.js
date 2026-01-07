import { parse } from '@astrojs/compiler/sync';
import * as prettierPluginBabel from 'prettier/plugins/babel';
import 'prettier';
import { serialize } from '@astrojs/compiler/utils';
import _doc from 'prettier/doc';
import { Buffer } from 'node:buffer';
import { SassFormatter } from 'sass-formatter';

const options = {
    astroAllowShorthand: {
        category: 'Astro',
        type: 'boolean',
        default: false,
        description: 'Enable/disable attribute shorthand if attribute name and expression are the same',
    },
    astroSkipFrontmatter: {
        category: 'Astro',
        type: 'boolean',
        default: false,
        description: 'Skips the formatting of the frontmatter.',
    },
};

const selfClosingTags = [
    'area',
    'base',
    'basefont',
    'bgsound',
    'br',
    'col',
    'command',
    'embed',
    'frame',
    'hr',
    'image',
    'img',
    'input',
    'isindex',
    'keygen',
    'link',
    'menuitem',
    'meta',
    'nextid',
    'param',
    'slot',
    'source',
    'track',
    'wbr',
];
const blockElements = [
    'address',
    'article',
    'aside',
    'blockquote',
    'details',
    'dialog',
    'dd',
    'div',
    'dl',
    'dt',
    'fieldset',
    'figcaption',
    'figure',
    'footer',
    'form',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'header',
    'hgroup',
    'hr',
    'li',
    'main',
    'nav',
    'ol',
    'p',
    'pre',
    'section',
    'table',
    'ul',
    'title',
    'html',
];
const formattableAttributes = [];

const openingBracketReplace = '_Pé';
const closingBracketReplace = 'èP_';
const atSignReplace = 'ΩP_';
const dotReplace = 'ωP_';
const interrogationReplace = 'ΔP_';
function isInlineElement(path, opts, node) {
    return node && isTagLikeNode(node) && !isBlockElement(node, opts) && !isPreTagContent(path);
}
function isBlockElement(node, opts) {
    return (node &&
        node.type === 'element' &&
        opts.htmlWhitespaceSensitivity !== 'strict' &&
        (opts.htmlWhitespaceSensitivity === 'ignore' || blockElements.includes(node.name)));
}
function isIgnoreDirective(node) {
    return node.type === 'comment' && node.value.trim() === 'prettier-ignore';
}
function printRaw(node, stripLeadingAndTrailingNewline = false) {
    if (!isNodeWithChildren(node)) {
        return '';
    }
    if (node.children.length === 0) {
        return '';
    }
    let raw = node.children.reduce((prev, curr) => prev + serialize(curr), '');
    if (!stripLeadingAndTrailingNewline) {
        return raw;
    }
    if (startsWithLinebreak(raw)) {
        raw = raw.substring(raw.indexOf('\n') + 1);
    }
    if (endsWithLinebreak(raw)) {
        raw = raw.substring(0, raw.lastIndexOf('\n'));
        if (raw.charAt(raw.length - 1) === '\r') {
            raw = raw.substring(0, raw.length - 1);
        }
    }
    return raw;
}
function isNodeWithChildren(node) {
    return node && 'children' in node && Array.isArray(node.children);
}
const isEmptyTextNode = (node) => {
    return !!node && node.type === 'text' && getUnencodedText(node).trim() === '';
};
function getUnencodedText(node) {
    return node.value;
}
function isTextNodeStartingWithLinebreak(node, nrLines = 1) {
    return startsWithLinebreak(getUnencodedText(node), nrLines);
}
function startsWithLinebreak(text, nrLines = 1) {
    return new RegExp(`^([\\t\\f\\r ]*\\n){${nrLines}}`).test(text);
}
function endsWithLinebreak(text, nrLines = 1) {
    return new RegExp(`(\\n[\\t\\f\\r ]*){${nrLines}}$`).test(text);
}
function isTextNodeStartingWithWhitespace(node) {
    return isTextNode(node) && /^\s/.test(getUnencodedText(node));
}
function endsWithWhitespace(text) {
    return /\s$/.test(text);
}
function isTextNodeEndingWithWhitespace(node) {
    return isTextNode(node) && endsWithWhitespace(getUnencodedText(node));
}
function hasSetDirectives(node) {
    const attributes = Array.from(node.attributes, (attr) => attr.name);
    return attributes.some((attr) => ['set:html', 'set:text'].includes(attr));
}
function shouldHugStart(node, opts) {
    if (isBlockElement(node, opts)) {
        return false;
    }
    if (!isNodeWithChildren(node)) {
        return false;
    }
    const children = node.children;
    if (children.length === 0) {
        return true;
    }
    const firstChild = children[0];
    return !isTextNodeStartingWithWhitespace(firstChild);
}
function shouldHugEnd(node, opts) {
    if (isBlockElement(node, opts)) {
        return false;
    }
    if (!isNodeWithChildren(node)) {
        return false;
    }
    const children = node.children;
    if (children.length === 0) {
        return true;
    }
    const lastChild = children[children.length - 1];
    if (isExpressionNode(lastChild))
        return true;
    if (isTagLikeNode(lastChild))
        return true;
    return !isTextNodeEndingWithWhitespace(lastChild);
}
function canOmitSoftlineBeforeClosingTag(path, opts) {
    return isLastChildWithinParentBlockElement(path, opts);
}
function getChildren(node) {
    return isNodeWithChildren(node) ? node.children : [];
}
function isLastChildWithinParentBlockElement(path, opts) {
    const parent = path.getParentNode();
    if (!parent || !isBlockElement(parent, opts)) {
        return false;
    }
    const children = getChildren(parent);
    const lastChild = children[children.length - 1];
    return lastChild === path.getNode();
}
function trimTextNodeLeft(node) {
    node.value = node.value && node.value.trimStart();
}
function trimTextNodeRight(node) {
    node.value = node.value && node.value.trimEnd();
}
function printClassNames(value) {
    const lines = value.trim().split(/[\r\n]+/);
    const formattedLines = lines.map((line) => {
        const spaces = line.match(/^\s+/);
        return (spaces ? spaces[0] : '') + line.trim().split(/\s+/).join(' ');
    });
    return formattedLines.join('\n');
}
function manualDedent(input) {
    let minTabSize = Infinity;
    let result = input;
    result = result.replace(/\r\n/g, '\n');
    let char = '';
    for (const line of result.split('\n')) {
        if (!line)
            continue;
        if (line[0] && /^[^\s]/.test(line[0])) {
            minTabSize = 0;
            break;
        }
        const match = line.match(/^(\s+)\S+/);
        if (match) {
            if (match[1] && !char)
                char = match[1][0];
            if (match[1].length < minTabSize)
                minTabSize = match[1].length;
        }
    }
    if (minTabSize > 0 && Number.isFinite(minTabSize)) {
        result = result.replace(new RegExp(`^${new Array(minTabSize + 1).join(char)}`, 'gm'), '');
    }
    return {
        tabSize: minTabSize === Infinity ? 0 : minTabSize,
        char,
        result,
    };
}
function isTextNode(node) {
    return node.type === 'text';
}
function isExpressionNode(node) {
    return node.type === 'expression';
}
function isTagLikeNode(node) {
    return (node.type === 'element' ||
        node.type === 'component' ||
        node.type === 'custom-element' ||
        node.type === 'fragment');
}
function getSiblings(path) {
    const parent = path.getParentNode();
    if (!parent)
        return [];
    return getChildren(parent);
}
function getNextNode(path) {
    const node = path.getNode();
    if (node) {
        const siblings = getSiblings(path);
        if (node.position?.start === siblings[siblings.length - 1].position?.start)
            return null;
        for (let i = 0; i < siblings.length; i++) {
            const sibling = siblings[i];
            if (sibling.position?.start === node.position?.start && i !== siblings.length - 1) {
                return siblings[i + 1];
            }
        }
    }
    return null;
}
const isPreTagContent = (path) => {
    if (!path || !path.stack || !Array.isArray(path.stack))
        return false;
    return path.stack.some((node) => (node.type === 'element' && node.name.toLowerCase() === 'pre') ||
        (node.type === 'attribute' && !formattableAttributes.includes(node.name)));
};
function getPreferredQuote(rawContent, preferredQuote) {
    const double = { quote: '"', regex: /"/g, escaped: '&quot;' };
    const single = { quote: "'", regex: /'/g, escaped: '&apos;' };
    const preferred = preferredQuote === "'" ? single : double;
    const alternate = preferred === single ? double : single;
    let result = preferred;
    if (rawContent.includes(preferred.quote) || rawContent.includes(alternate.quote)) {
        const numPreferredQuotes = (rawContent.match(preferred.regex) || []).length;
        const numAlternateQuotes = (rawContent.match(alternate.regex) || []).length;
        result = numPreferredQuotes > numAlternateQuotes ? alternate : preferred;
    }
    return result;
}
function inferParserByTypeAttribute(type) {
    if (!type) {
        return 'babel-ts';
    }
    switch (type) {
        case 'module':
        case 'text/javascript':
        case 'text/babel':
        case 'application/javascript':
            return 'babel';
        case 'application/x-typescript':
            return 'babel-ts';
        case 'text/markdown':
            return 'markdown';
        case 'text/html':
            return 'html';
        case 'text/x-handlebars-template':
            return 'glimmer';
        default:
            if (type.endsWith('json') || type.endsWith('importmap') || type === 'speculationrules') {
                return 'json';
            }
            return 'babel-ts';
    }
}

const { builders: { breakParent, dedent, fill, group: group$1, indent: indent$1, join: join$1, line: line$1, softline: softline$1, hardline: hardline$1, literalline, }, utils: { stripTrailingHardline: stripTrailingHardline$1 }, } = _doc;
let ignoreNext = false;
function print(path, opts, print) {
    const node = path.node;
    if (!node) {
        return '';
    }
    if (ignoreNext && !isEmptyTextNode(node)) {
        ignoreNext = false;
        return [
            opts.originalText
                .slice(opts.locStart(node), opts.locEnd(node))
                .split('\n')
                .map((lineContent, i) => (i == 0 ? [lineContent] : [literalline, lineContent]))
                .flat(),
        ];
    }
    if (typeof node === 'string') {
        return node;
    }
    switch (node.type) {
        case 'root': {
            return [stripTrailingHardline$1(path.map(print, 'children')), hardline$1];
        }
        case 'text': {
            const rawText = getUnencodedText(node);
            if (isEmptyTextNode(node)) {
                const hasWhiteSpace = rawText.trim().length < getUnencodedText(node).length;
                const hasOneOrMoreNewlines = /\n/.test(getUnencodedText(node));
                const hasTwoOrMoreNewlines = /\n\r?\s*\n\r?/.test(getUnencodedText(node));
                if (hasTwoOrMoreNewlines) {
                    return [hardline$1, hardline$1];
                }
                if (hasOneOrMoreNewlines) {
                    return hardline$1;
                }
                if (hasWhiteSpace) {
                    return line$1;
                }
                return '';
            }
            return fill(splitTextToDocs(node));
        }
        case 'component':
        case 'fragment':
        case 'custom-element':
        case 'element': {
            let isEmpty;
            if (!node.children) {
                isEmpty = true;
            }
            else {
                isEmpty = node.children.every((child) => isEmptyTextNode(child));
            }
            const isSelfClosingTag = isEmpty &&
                (node.type === 'component' ||
                    selfClosingTags.includes(node.name) ||
                    hasSetDirectives(node));
            const isSingleLinePerAttribute = opts.singleAttributePerLine && node.attributes.length > 1;
            const attributeLine = isSingleLinePerAttribute ? breakParent : '';
            const attributes = join$1(attributeLine, path.map(print, 'attributes'));
            if (isSelfClosingTag) {
                return group$1(['<', node.name, indent$1(attributes), line$1, `/>`]);
            }
            if (node.children) {
                const children = node.children;
                const firstChild = children[0];
                const lastChild = children[children.length - 1];
                let noHugSeparatorStart = softline$1;
                let noHugSeparatorEnd = softline$1;
                const hugStart = shouldHugStart(node, opts);
                const hugEnd = shouldHugEnd(node, opts);
                let body;
                if (isEmpty) {
                    body =
                        isInlineElement(path, opts, node) &&
                            node.children.length &&
                            isTextNodeStartingWithWhitespace(node.children[0]) &&
                            !isPreTagContent(path)
                            ? () => line$1
                            : () => softline$1;
                }
                else if (isPreTagContent(path)) {
                    body = () => printRaw(node);
                }
                else if (isInlineElement(path, opts, node) && !isPreTagContent(path)) {
                    body = () => path.map(print, 'children');
                }
                else {
                    body = () => path.map(print, 'children');
                }
                const openingTag = [
                    '<',
                    node.name,
                    indent$1(group$1([
                        attributes,
                        hugStart
                            ? ''
                            : !isPreTagContent(path) && !opts.bracketSameLine
                                ? dedent(softline$1)
                                : '',
                    ])),
                ];
                if (hugStart && hugEnd) {
                    const huggedContent = [
                        isSingleLinePerAttribute ? hardline$1 : softline$1,
                        group$1(['>', body(), `</${node.name}`]),
                    ];
                    const omitSoftlineBeforeClosingTag = isEmpty || canOmitSoftlineBeforeClosingTag(path, opts);
                    return group$1([
                        ...openingTag,
                        isEmpty ? group$1(huggedContent) : group$1(indent$1(huggedContent)),
                        omitSoftlineBeforeClosingTag ? '' : softline$1,
                        '>',
                    ]);
                }
                if (isPreTagContent(path)) {
                    noHugSeparatorStart = '';
                    noHugSeparatorEnd = '';
                }
                else {
                    let didSetEndSeparator = false;
                    if (!hugStart && firstChild && isTextNode(firstChild)) {
                        if (isTextNodeStartingWithLinebreak(firstChild) &&
                            firstChild !== lastChild &&
                            (!isInlineElement(path, opts, node) || isTextNodeEndingWithWhitespace(lastChild))) {
                            noHugSeparatorStart = hardline$1;
                            noHugSeparatorEnd = hardline$1;
                            didSetEndSeparator = true;
                        }
                        else if (isInlineElement(path, opts, node)) {
                            noHugSeparatorStart = line$1;
                        }
                        trimTextNodeLeft(firstChild);
                    }
                    if (!hugEnd && lastChild && isTextNode(lastChild)) {
                        if (isInlineElement(path, opts, node) && !didSetEndSeparator) {
                            noHugSeparatorEnd = line$1;
                        }
                        trimTextNodeRight(lastChild);
                    }
                }
                if (hugStart) {
                    return group$1([
                        ...openingTag,
                        indent$1([softline$1, group$1(['>', body()])]),
                        noHugSeparatorEnd,
                        `</${node.name}>`,
                    ]);
                }
                if (hugEnd) {
                    return group$1([
                        ...openingTag,
                        '>',
                        indent$1([noHugSeparatorStart, group$1([body(), `</${node.name}`])]),
                        canOmitSoftlineBeforeClosingTag(path, opts) ? '' : softline$1,
                        '>',
                    ]);
                }
                if (isEmpty) {
                    return group$1([...openingTag, '>', body(), `</${node.name}>`]);
                }
                return group$1([
                    ...openingTag,
                    '>',
                    indent$1([noHugSeparatorStart, body()]),
                    noHugSeparatorEnd,
                    `</${node.name}>`,
                ]);
            }
            return '';
        }
        case 'attribute': {
            const name = node.name.trim();
            switch (node.kind) {
                case 'empty':
                    return [line$1, name];
                case 'expression':
                    return '';
                case 'quoted':
                    let value = node.value;
                    if (node.name === 'class') {
                        value = printClassNames(value);
                    }
                    const unescapedValue = value.replace(/&apos;/g, "'").replace(/&quot;/g, '"');
                    const { escaped, quote, regex } = getPreferredQuote(unescapedValue, opts.jsxSingleQuote ? "'" : '"');
                    const result = unescapedValue.replace(regex, escaped);
                    return [line$1, name, '=', quote, result, quote];
                case 'shorthand':
                    return [line$1, '{', name, '}'];
                case 'spread':
                    return [line$1, '{...', name, '}'];
                case 'template-literal':
                    return [line$1, name, '=', '`', node.value, '`'];
            }
            return '';
        }
        case 'doctype': {
            return ['<!doctype html>', hardline$1];
        }
        case 'comment':
            if (isIgnoreDirective(node)) {
                ignoreNext = true;
            }
            const nextNode = getNextNode(path);
            let trailingLine = '';
            if (nextNode && isTagLikeNode(nextNode)) {
                trailingLine = hardline$1;
            }
            return ['<!--', getUnencodedText(node), '-->', trailingLine];
        default: {
            throw new Error(`Unhandled node type "${node.type}"!`);
        }
    }
}
function splitTextToDocs(node) {
    const text = getUnencodedText(node);
    const textLines = text.split(/[\t\n\f\r ]+/);
    let docs = join$1(line$1, textLines).filter((doc) => doc !== '');
    if (startsWithLinebreak(text)) {
        docs[0] = hardline$1;
    }
    if (startsWithLinebreak(text, 2)) {
        docs = [hardline$1, ...docs];
    }
    if (endsWithLinebreak(text)) {
        docs[docs.length - 1] = hardline$1;
    }
    if (endsWithLinebreak(text, 2)) {
        docs = [...docs, hardline$1];
    }
    return docs;
}

const { builders: { group, indent, join, line, softline, hardline, lineSuffixBoundary }, utils: { stripTrailingHardline, mapDoc }, } = _doc;
const supportedStyleLangValues = ['css', 'scss', 'sass', 'less'];
const embed = ((path, options) => {
    const parserOption = options;
    return async (textToDoc, print) => {
        const node = path.node;
        if (!node)
            return undefined;
        if (node.type === 'expression') {
            const jsxNode = makeNodeJSXCompatible(node);
            const textContent = printRaw(jsxNode);
            let content;
            content = await wrapParserTryCatch(textToDoc, textContent, {
                ...options,
                parser: 'astroExpressionParser',
            });
            content = stripTrailingHardline(content);
            const strings = [];
            mapDoc(content, (doc) => {
                if (typeof doc === 'string') {
                    strings.push(doc);
                }
            });
            if (strings.every((value) => value.startsWith('//'))) {
                return group(['{', content, softline, lineSuffixBoundary, '}']);
            }
            const astroDoc = mapDoc(content, (doc) => {
                if (typeof doc === 'string') {
                    doc = doc.replaceAll(openingBracketReplace, '{');
                    doc = doc.replaceAll(closingBracketReplace, '}');
                    doc = doc.replaceAll(atSignReplace, '@');
                    doc = doc.replaceAll(dotReplace, '.');
                    doc = doc.replaceAll(interrogationReplace, '?');
                }
                return doc;
            });
            return group(['{', indent([softline, astroDoc]), softline, lineSuffixBoundary, '}']);
        }
        if (node.type === 'attribute' && node.kind === 'expression') {
            const value = node.value.trim();
            const name = node.name.trim();
            const attrNodeValue = await wrapParserTryCatch(textToDoc, value, {
                ...options,
                parser: 'astroExpressionParser',
            });
            if (name === value && options.astroAllowShorthand) {
                return [line, '{', attrNodeValue, '}'];
            }
            return [line, name, '=', '{', attrNodeValue, '}'];
        }
        if (node.type === 'attribute' && node.kind === 'spread') {
            const spreadContent = await wrapParserTryCatch(textToDoc, node.name, {
                ...options,
                parser: 'astroExpressionParser',
            });
            return [line, '{...', spreadContent, '}'];
        }
        if (node.type === 'frontmatter') {
            if (options.astroSkipFrontmatter) {
                return [group(['---', node.value, '---', hardline]), hardline];
            }
            const frontmatterContent = await wrapParserTryCatch(textToDoc, node.value, {
                ...options,
                parser: 'babel-ts',
            });
            return [group(['---', hardline, frontmatterContent, hardline, '---', hardline]), hardline];
        }
        if (node.type === 'element' && node.name === 'script' && node.children.length) {
            const typeAttribute = node.attributes.find((attr) => attr.name === 'type')?.value;
            let parser = 'babel-ts';
            if (typeAttribute) {
                parser = inferParserByTypeAttribute(typeAttribute);
            }
            const scriptContent = printRaw(node);
            let formattedScript = await wrapParserTryCatch(textToDoc, scriptContent, {
                ...options,
                parser: parser,
            });
            formattedScript = stripTrailingHardline(formattedScript);
            const isEmpty = /^\s*$/.test(scriptContent);
            const attributes = path.map(print, 'attributes');
            const openingTag = group(['<script', indent(group(attributes)), softline, '>']);
            return [
                openingTag,
                indent([isEmpty ? '' : hardline, formattedScript]),
                isEmpty ? '' : hardline,
                '</script>',
            ];
        }
        if (node.type === 'element' && node.name === 'style') {
            const content = printRaw(node);
            let parserLang = 'css';
            if (node.attributes) {
                const langAttribute = node.attributes.filter((x) => x.name === 'lang');
                if (langAttribute.length) {
                    const styleLang = langAttribute[0].value.toLowerCase();
                    parserLang = supportedStyleLangValues.includes(styleLang) ? styleLang : undefined;
                }
            }
            return await embedStyle(parserLang, content, path, print, textToDoc, parserOption);
        }
        return undefined;
    };
});
async function wrapParserTryCatch(cb, text, options) {
    try {
        return await cb(text, options);
    }
    catch (e) {
        process.env.PRETTIER_DEBUG = 'true';
        throw e;
    }
}
function makeNodeJSXCompatible(node) {
    const newNode = { ...node };
    const childBundle = [];
    let childBundleIndex = 0;
    if (isNodeWithChildren(newNode)) {
        newNode.children = newNode.children.reduce((result, child, index) => {
            const previousChildren = newNode.children[index - 1];
            const nextChildren = newNode.children[index + 1];
            if (isTagLikeNode(child)) {
                child.attributes = child.attributes.map(makeAttributeJSXCompatible);
                if (!childBundle[childBundleIndex]) {
                    childBundle[childBundleIndex] = [];
                }
                if (isNodeWithChildren(child)) {
                    child = makeNodeJSXCompatible(child);
                }
                if ((!previousChildren || isTextNode(previousChildren)) &&
                    nextChildren &&
                    isTagLikeNode(nextChildren)) {
                    childBundle[childBundleIndex].push(child);
                    return result;
                }
                if (previousChildren &&
                    isTagLikeNode(previousChildren) &&
                    nextChildren &&
                    isTagLikeNode(nextChildren)) {
                    childBundle[childBundleIndex].push(child);
                    return result;
                }
                if ((!nextChildren || isTextNode(nextChildren)) &&
                    childBundle[childBundleIndex].length > 0) {
                    childBundle[childBundleIndex].push(child);
                    const parentNode = {
                        type: 'fragment',
                        name: '',
                        attributes: [],
                        children: childBundle[childBundleIndex],
                    };
                    childBundleIndex += 1;
                    result.push(parentNode);
                    return result;
                }
            }
            else {
                childBundleIndex += 1;
            }
            result.push(child);
            return result;
        }, []);
    }
    return newNode;
    function makeAttributeJSXCompatible(attr) {
        if (attr.kind === 'shorthand') {
            attr.kind = 'empty';
            attr.name = openingBracketReplace + attr.name + closingBracketReplace;
        }
        if (attr.kind !== 'spread') {
            if (attr.name.includes('@')) {
                attr.name = attr.name.replaceAll('@', atSignReplace);
            }
            if (attr.name.includes('.')) {
                attr.name = attr.name.replaceAll('.', dotReplace);
            }
            if (attr.name.includes('?')) {
                attr.name = attr.name.replaceAll('?', interrogationReplace);
            }
        }
        return attr;
    }
}
async function embedStyle(lang, content, path, print, textToDoc, options) {
    const isEmpty = /^\s*$/.test(content);
    switch (lang) {
        case 'less':
        case 'css':
        case 'scss': {
            let formattedStyles = await wrapParserTryCatch(textToDoc, content, {
                ...options,
                parser: lang,
            });
            formattedStyles = stripTrailingHardline(formattedStyles);
            const attributes = path.map(print, 'attributes');
            const openingTag = group(['<style', indent(group(attributes)), softline, '>']);
            return [
                openingTag,
                indent([isEmpty ? '' : hardline, formattedStyles]),
                isEmpty ? '' : hardline,
                '</style>',
            ];
        }
        case 'sass': {
            const lineEnding = options?.endOfLine?.toUpperCase() === 'CRLF' ? 'CRLF' : 'LF';
            const sassOptions = {
                tabSize: options.tabWidth,
                insertSpaces: !options.useTabs,
                lineEnding,
            };
            const { result: raw } = manualDedent(content);
            const formattedSassIndented = SassFormatter.Format(raw, sassOptions).trim();
            const formattedSass = join(hardline, formattedSassIndented.split('\n'));
            const attributes = path.map(print, 'attributes');
            const openingTag = group(['<style', indent(group(attributes)), softline, '>']);
            return [
                openingTag,
                indent([isEmpty ? '' : hardline, formattedSass]),
                isEmpty ? '' : hardline,
                '</style>',
            ];
        }
        case undefined: {
            const node = path.getNode();
            if (node) {
                return Buffer.from(options.originalText)
                    .subarray(options.locStart(node), options.locEnd(node))
                    .toString();
            }
            return undefined;
        }
    }
}

const babelParser = prettierPluginBabel.parsers['babel-ts'];
const languages = [
    {
        name: 'astro',
        parsers: ['astro'],
        extensions: ['.astro'],
        vscodeLanguageIds: ['astro'],
    },
];
const parsers = {
    astro: {
        parse: (source) => parse(source, { position: true }).ast,
        astFormat: 'astro',
        locStart: (node) => node.position.start.offset,
        locEnd: (node) => node.position.end.offset,
    },
    astroExpressionParser: {
        ...babelParser,
        preprocess(text) {
            return `<>{${text}\n}</>`;
        },
        parse(text, opts) {
            const ast = babelParser.parse(text, opts);
            return {
                ...ast,
                program: ast.program.body[0].expression.children[0].expression,
            };
        },
    },
};
const printers = {
    astro: {
        print,
        embed,
    },
};
const defaultOptions = {
    tabWidth: 2,
};

export { defaultOptions, languages, options, parsers, printers };
//# sourceMappingURL=index.js.map
