# vim-bloc-plugin

This plugin was designed to be similar the [vscode extension](https://github.com/felangel/bloc/tree/master/extensions/vscode).

Generating the Flutter Bloc or Cubit files.


## Installation

Assuming you are using vim-plug as plugin manager, you can just put it in yout `init.vim`

```bash
Plug 'felangel/bloc', { 'rtp': 'extension/vim' }
```

run `:PlugInstall`, after that, you must source your `.vimrc`

## Usage

After your had installed the plugin, it enable two new commands

```bash
:Bloc <BlocName> <DestinationFolder>
```

- BlocName: Is the name will be used to generate all bloc files and classes
    - **This name must be a CamelCase**
- DestinationFolder: Is the path to generate the files, like: `lib/posts`
    - **Don't start with `/`**


```bash
:Cubit <CubitName> <DestinationFolder>
```

- CubitName: Is the name will be used to generate all cubit files and classes
    - **This name must be a CamelCase**
- DestinationFolder: Is the path to generate the files, like: `lib/posts`
    - **Don't start with `/`**

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)
