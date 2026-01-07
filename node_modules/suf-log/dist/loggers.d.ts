import { LogMessage, LogStyle, LogTableInput } from './interfaces';
/**works in node and the browser.*/
export declare function Log(...messages: (string | LogMessage)[]): void;
export interface LogTableOptions {
    padding?: number;
    spacing?: number;
}
/**node only*/
export declare function LogTable(table: LogTableInput, options?: LogTableOptions): void;
/**works in the browser and node. */
export declare function LogS(styles: LogStyle[], ...messages: string[]): void;
/**Log a single message with an optional style, works in the browser and node. */
export declare function LogSingle(message: string, style?: LogStyle): void;
