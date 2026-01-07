import { TransformOptions, TransformResult, ParseOptions, ParseResult, ConvertToTSXOptions, TSXResult, transform as transform$1, parse as parse$1, convertToTSX as convertToTSX$1 } from '../shared/types.js';
import '../shared/ast.js';
import '../shared/diagnostics.js';

type UnwrappedPromise<T> = T extends (...params: any) => Promise<infer Return> ? (...params: Parameters<T>) => Return : T;
interface Service {
    transform: UnwrappedPromise<typeof transform$1>;
    parse: UnwrappedPromise<typeof parse$1>;
    convertToTSX: UnwrappedPromise<typeof convertToTSX$1>;
}
declare const transform: (input: string, options: TransformOptions | undefined) => TransformResult;
declare const parse: (input: string, options: ParseOptions | undefined) => ParseResult;
declare const convertToTSX: (input: string, options: ConvertToTSXOptions | undefined) => TSXResult;
declare function startRunningService(): Service;

export { convertToTSX, parse, startRunningService, transform };
