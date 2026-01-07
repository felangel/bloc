import { LogTableInput } from './interfaces';
export declare let isBrowser: boolean;
export declare const defaultLogTableOptions: {
    padding: number;
    spacing: number;
};
/**
 * Can be used to change the assumed environment
 */
export declare function SetLoggerEnvironment(env: 'node' | 'browser'): void;
export declare function stringColorToAnsiColor(type: 'background' | 'color', color?: string): string | undefined;
export declare function ANSICodes(type: 'background' | 'color' | 'bold' | 'reset'): "0" | "1" | "38" | "48";
export declare function maxTableColumnLength(column: LogTableInput[0]): number;
export declare function removeNodeStyles(item: string | number): string;
export declare function pad(text: string, start: number, end: number): string;
export declare function getColumn(matrix: LogTableInput, col: number): (string | number | import("./interfaces").LogMessage)[];
export declare function addReset(input: number | string): string;
