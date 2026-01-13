<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/logos/bloc_tools.png" height="100" alt="Bloc Tools" />
</p>

<p align="center">
<a href="https://pub.dev/packages/bloc_tools"><img src="https://img.shields.io/pub/v/bloc_tools.svg" alt="Pub"></a>
<a href="https://github.com/felangel/bloc/actions"><img src="https://github.com/felangel/bloc/actions/workflows/main.yaml/badge.svg" alt="build"></a>
<a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://pub.dev/packages/bloc_lint"><img src="https://img.shields.io/badge/style-bloc_lint-20FFE4.svg" alt="style: bloc lint"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
<a href="https://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://discord.gg/bloc"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

Tools for building applications using the bloc state management library.

## Sponsors

Our top sponsors are shown below! [[Become a Sponsor](https://github.com/sponsors/felangel)]

<table style="background-color: white; border: 1px solid black">
    <tbody>
        <tr>
            <td align="center" style="border: 1px solid black">
                <a href="https://shorebird.dev"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/shorebird.png" width="225"/></a>
            </td>            
            <td align="center" style="border: 1px solid black">
                <a href="https://getstream.io/chat/flutter/tutorial/?utm_source=Github&utm_medium=Github_Repo_Content_Ad&utm_content=Developer&utm_campaign=Github_Jan2022_FlutterChat&utm_term=bloc"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/stream.png" width="225"/></a>
            </td>
            <td align="center" style="border: 1px solid black">
                <a href="https://rettelgame.com/"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/rettel.png" width="225"/></a>
            </td>
        </tr>
    </tbody>
</table>

---

## Installing

```sh
dart pub global activate bloc_tools
```

## Commands

### `$ bloc lint [files...]`

Analyze Dart source code using the official bloc linter to improve code quality and enforce consistency.

**Usage**

```sh
# Lint the current directory
bloc lint .

# Lint multiple files
bloc lint ./path/to/bloc.dart ./path/to/cubit.dart
```

Check out the [official documentation](https://bloclibrary.dev/lint/) for information.

### `$ bloc new [component]`

Create new bloc/cubit components from various templates.

**Usage**

```sh
# Create a CounterBloc
bloc new bloc --name counter

# Create a CounterCubit
bloc new cubit --name counter
```

**Components**

| Component      | Description                  |
| -------------- | ---------------------------- |
| bloc           | Generate a new Bloc          |
| cubit          | Generate a new Cubit         |
| hydrated_bloc  | Generate a new HydratedBloc  |
| hydrated_cubit | Generate a new HydratedCubit |
| replay_bloc    | Generate a new ReplayBloc    |
| replay_cubit   | Generate a new ReplayCubit   |

## Usage

```sh
Command Line Tools for the Bloc Library.

Usage: bloc <command> [arguments]

Global options:
-h, --help       Print this usage information.
    --version    Print the current version.

Available commands:
  lint   bloc lint [arguments]
         Lint Dart source code.
  new    bloc new <subcommand> [arguments]
         Generate new bloc components.

Run "bloc help <command>" for more information about a command.
```
