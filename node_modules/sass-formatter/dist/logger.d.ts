import { SassTextLine } from './sassTextLine';
export interface LogFormatInfo {
    title: string;
    debug: boolean;
    lineNumber: number;
    oldLineText: string;
    newLineText?: string;
    offset?: number;
    originalOffset?: number;
    replaceSpaceOrTabs?: boolean;
    nextLine?: SassTextLine;
}
export interface LogConvertData {
    type: string;
    text: string;
}
export declare function LogDebugResult(result: string): void;
export declare function ResetDebugLog(): void;
export declare function SetDebugLOCAL_CONTEXT(data: any): void;
export declare function SetConvertData(data: LogConvertData): void;
export declare function PushDebugInfo(info: LogFormatInfo): void;
