type ParentNode = RootNode | ElementNode | ComponentNode | CustomElementNode | FragmentNode | ExpressionNode;
type LiteralNode = TextNode | DoctypeNode | CommentNode | FrontmatterNode;
type Node = RootNode | ElementNode | ComponentNode | CustomElementNode | FragmentNode | ExpressionNode | TextNode | FrontmatterNode | DoctypeNode | CommentNode;
interface Position {
    start: Point;
    end?: Point;
}
interface Point {
    /** 1-based line number */
    line: number;
    /** 1-based column number, per-line */
    column: number;
    /** 0-based byte offset */
    offset: number;
}
interface BaseNode {
    type: string;
    position?: Position;
}
interface ParentLikeNode extends BaseNode {
    type: 'element' | 'component' | 'custom-element' | 'fragment' | 'expression' | 'root';
    children: Node[];
}
interface ValueNode extends BaseNode {
    value: string;
}
interface RootNode extends ParentLikeNode {
    type: 'root';
}
interface AttributeNode extends BaseNode {
    type: 'attribute';
    kind: 'quoted' | 'empty' | 'expression' | 'spread' | 'shorthand' | 'template-literal';
    name: string;
    value: string;
    raw?: string;
}
interface TextNode extends ValueNode {
    type: 'text';
}
interface ElementNode extends ParentLikeNode {
    type: 'element';
    name: string;
    attributes: AttributeNode[];
}
interface FragmentNode extends ParentLikeNode {
    type: 'fragment';
    name: string;
    attributes: AttributeNode[];
}
interface ComponentNode extends ParentLikeNode {
    type: 'component';
    name: string;
    attributes: AttributeNode[];
}
interface CustomElementNode extends ParentLikeNode {
    type: 'custom-element';
    name: string;
    attributes: AttributeNode[];
}
type TagLikeNode = ElementNode | FragmentNode | ComponentNode | CustomElementNode;
interface DoctypeNode extends ValueNode {
    type: 'doctype';
}
interface CommentNode extends ValueNode {
    type: 'comment';
}
interface FrontmatterNode extends ValueNode {
    type: 'frontmatter';
}
interface ExpressionNode extends ParentLikeNode {
    type: 'expression';
}

export { AttributeNode, BaseNode, CommentNode, ComponentNode, CustomElementNode, DoctypeNode, ElementNode, ExpressionNode, FragmentNode, FrontmatterNode, LiteralNode, Node, ParentLikeNode, ParentNode, Point, Position, RootNode, TagLikeNode, TextNode, ValueNode };
