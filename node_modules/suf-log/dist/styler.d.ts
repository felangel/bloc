import { LogStyle } from './interfaces';
/**
 * this function is not browser compatible*.
 * @example ```ts
 * console.log(styler('test', 'red'))
 * ```
 *
 * *you have to add the styles manually, use the Log function for browser compatibly.
 */
export declare function styler(input: string, style?: LogStyle): string;
