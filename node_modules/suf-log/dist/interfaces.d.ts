/**
 * color/background/font-weight work in node and the browser, the other properties only work in the browser.
 */
export declare type LogStyle = string | {
    /**node and browser support */
    background?: string;
    /**node and browser support */
    color?: string;
    /**browser only */
    padding?: string;
    /**browser only */
    margin?: string;
    /**browser only, set to inline-block by default. */
    display?: string;
    /**browser only */
    border?: string;
    /**browser only */
    'border-radius'?: string;
    /**browser only */
    'text-align'?: string;
    /**browser only */
    'text-shadow'?: string;
    /**browser only */
    'font-size'?: string;
    /** for bold text in node add the value 'bold' */
    'font-weight'?: 'bold' | 'normal' | 'bolder' | 'lighter' | '100' | '200' | '300' | '400' | '500' | '600' | '700' | '800' | '900';
    [key: string]: string | undefined;
};
export declare type LogMessage = {
    message: string;
    style?: LogStyle;
};
export declare type LogTableInput = (number | string | LogMessage)[][];
