import { SassFormatterConfig } from './config';
export { SassFormatterConfig, defaultSassFormatterConfig } from './config';
export declare class SassFormatter {
    static Format(text: string, config?: Partial<SassFormatterConfig>): string;
    private static formatLine;
    private static handleCommentBlock;
    private static handleEmptyLine;
    private static isBlockHeader;
    private static isProperty;
    /** Adds new Line If not first line. */
    private static addNewLine;
}
