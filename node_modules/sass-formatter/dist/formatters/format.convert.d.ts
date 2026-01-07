import { FormattingState } from '../state';
/** converts scss/css to sass. */
export declare function convertScssOrCss(text: string, STATE: FormattingState): {
    lastSelector: string;
    text: string;
};
