## suf-log

<span id="BADGE_GENERATION_MARKER_0"></span>
[![circleci](https://img.shields.io/circleci/build/github/TheRealSyler/suf-log)](https://app.circleci.com/github/TheRealSyler/suf-log/pipelines) [![Custom](https://codecov.io/gh/TheRealSyler/suf-log/branch/master/graph/badge.svg)](https://codecov.io/gh/TheRealSyler/suf-log) [![npmV](https://img.shields.io/npm/v/suf-log?color=green)](https://www.npmjs.com/package/suf-log) [![min](https://img.shields.io/bundlephobia/min/suf-log)](https://bundlephobia.com/result?p=suf-log) [![install](https://badgen.net/packagephobia/install/suf-log)](https://packagephobia.now.sh/result?p=suf-log) [![githubLastCommit](https://img.shields.io/github/last-commit/TheRealSyler/suf-log)](https://github.com/TheRealSyler/suf-log)
<span id="BADGE_GENERATION_MARKER_1"></span>

<span id="DOC_GENERATION_MARKER_0"></span>

# Docs

- **[interfaces](#interfaces)**

  - [LogStyle](#logstyle)
  - [LogMessage](#logmessage)
  - [LogTableInput](#logtableinput)

- **[loggers](#loggers)**

  - [LogS](#logs)
  - [LogSingle](#logsingle)

- **[styler](#styler)**

  - [styler](#styler)

### interfaces

##### LogStyle

```typescript
/**
 * color/background/font-weight work in node and the browser, the other properties only work in the browser.
 */
type LogStyle = string | {
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
}
```

##### LogMessage

```typescript
type LogMessage = {
    message: string;
    style?: LogStyle;
}
```

##### LogTableInput

```typescript
type LogTableInput = (number | string | LogMessage)[][];
```

### loggers

##### LogS

```typescript
/**works in node and the browser.*/
function Log(...messages: (string | LogMessage)[]): void;
interface LogTableOptions {
    padding?: number;
    spacing?: number;
}
/**node only*/
function LogTable(table: LogTableInput, options?: LogTableOptions): void;
/**works in the browser and node. */
function LogS(styles: LogStyle[], ...messages: string[]): void;
```

##### LogSingle

```typescript
/**Log a single message with an optional style, works in the browser and node. */
function LogSingle(message: string, style?: LogStyle): void;
```

### styler

##### styler

```typescript
/**
 * this function is not browser compatible*.
 * @example ```ts
 * console.log(styler('test', 'red'))
 * ```
 *
 * *you have to add the styles manually, use the Log function for browser compatibly.
 */
function styler(input: string, style?: LogStyle): string;
```

_Generated with_ **[suf-cli](https://www.npmjs.com/package/suf-cli)**
<span id="DOC_GENERATION_MARKER_1"></span>

### License

<span id="LICENSE_GENERATION_MARKER_0"></span>
Copyright (c) 2020 Leonard Grosoli Licensed under the MIT license.
<span id="LICENSE_GENERATION_MARKER_1"></span>
