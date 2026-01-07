# Astro Compiler

Astro’s [Go](https://golang.org/) + WASM compiler.

## Install

```
npm install @astrojs/compiler
```

## Usage

#### Transform `.astro` to valid TypeScript

The Astro compiler can convert `.astro` syntax to a TypeScript Module whose default export generates HTML.

**Some notes**...

- TypeScript is valid `.astro` syntax! The output code may need an additional post-processing step to generate valid JavaScript.
- `.astro` files rely on a server implementation exposed as `astro/runtime/server/index.js` in the Node ecosystem. Other runtimes currently need to bring their own rendering implementation and reference it via `internalURL`. This is a pain point we're looking into fixing.

```js
import { transform, type TransformResult } from "@astrojs/compiler";

const result = await transform(source, {
  filename: "/Users/astro/Code/project/src/pages/index.astro",
  sourcemap: "both",
  internalURL: "astro/runtime/server/index.js",
});
```

#### Parse `.astro` and return an AST

The Astro compiler can emit an AST using the `parse` method.

**Some notes**...

- Position data is currently incomplete and in some cases incorrect. We're working on it!
- A `TextNode` can represent both HTML `text` and JavaScript/TypeScript source code.
- The `@astrojs/compiler/utils` entrypoint exposes `walk` and `walkAsync` functions that can be used to traverse the AST. It also exposes the `is` helper which can be used as guards to derive the proper types for each `node`.

```js
import { parse } from "@astrojs/compiler";
import { walk, walkAsync, is } from "@astrojs/compiler/utils";

const result = await parse(source, {
  position: false, // defaults to `true`
});

walk(result.ast, (node) => {
  // `tag` nodes are `element` | `custom-element` | `component`
  if (is.tag(node)) {
    console.log(node.name);
  }
});

await walkAsync(result.ast, async (node) => {
  if (is.tag(node)) {
    node.value = await expensiveCalculation(node)
  }
});
```

## Develop

### VSCode / CodeSpaces

A `devcontainer` configuration is available for use with VSCode's [Remote Development extension pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) and GitHub CodeSpaces.

## Contributing

[CONTRIBUTING.md](/CONTRIBUTING.md)
