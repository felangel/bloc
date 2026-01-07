import { Node, ParentNode, LiteralNode, TagLikeNode, TextNode, RootNode, ElementNode, CustomElementNode, ComponentNode, FragmentNode, ExpressionNode, DoctypeNode, CommentNode, FrontmatterNode } from '../shared/ast.js';

type Visitor = (node: Node, parent?: ParentNode, index?: number) => void | Promise<void>;
declare const is: {
    parent(node: Node): node is ParentNode;
    literal(node: Node): node is LiteralNode;
    tag(node: Node): node is TagLikeNode;
    whitespace(node: Node): node is TextNode;
    root: (node: Node) => node is RootNode;
    element: (node: Node) => node is ElementNode;
    customElement: (node: Node) => node is CustomElementNode;
    component: (node: Node) => node is ComponentNode;
    fragment: (node: Node) => node is FragmentNode;
    expression: (node: Node) => node is ExpressionNode;
    text: (node: Node) => node is TextNode;
    doctype: (node: Node) => node is DoctypeNode;
    comment: (node: Node) => node is CommentNode;
    frontmatter: (node: Node) => node is FrontmatterNode;
};
declare function walk(node: ParentNode, callback: Visitor): void;
declare function walkAsync(node: ParentNode, callback: Visitor): Promise<void>;
interface SerializeOptions {
    selfClose: boolean;
}
/** @deprecated Please use `SerializeOptions`  */
type SerializeOtions = SerializeOptions;
declare function serialize(root: Node, opts?: SerializeOptions): string;

export { SerializeOptions, SerializeOtions, Visitor, is, serialize, walk, walkAsync };
