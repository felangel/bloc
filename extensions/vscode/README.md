<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_logo_full.png" height="100" alt="Bloc" />
</p>

<p align="center">
<a href="https://github.com/felangel/bloc/actions"><img src="https://img.shields.io/github/workflow/status/felangel/bloc/build.svg?logo=github" alt="build"></a>
<a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc"><img src="https://vsmarketplacebadge.apphb.com/version-short/FelixAngelov.bloc.svg" alt="Version"></a>
<a href="https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc"><img src="https://vsmarketplacebadge.apphb.com/installs-short/FelixAngelov.bloc.svg" alt="Installs"></a>
<a href="https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc"><img src="https://vsmarketplacebadge.apphb.com/rating-short/FelixAngelov.bloc.svg" alt="Ratings"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
<a href="http://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://discord.gg/bloc"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

## Overview

[VSCode](https://code.visualstudio.com/) support for the [Bloc Library](https://bloclibrary.dev) and provides tools for effectively creating [Blocs](https://github.com/felangel/bloc) and [Cubits](https://github.com/felangel/cubit) for both [Flutter](https://flutter.dev/) and [AngularDart](https://angulardart.dev/) apps.

## Installation

Bloc can be installed from the [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) or by [searching within VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Commands

| Command            | Description          |
| ------------------ | -------------------- |
| `Bloc: New Bloc`   | Generate a new Bloc  |
| `Cubit: New Cubit` | Generate a new Cubit |

You can activate the commands by launching the command palette (View -> Command Palette) and running entering the command name or you can right click on the directory in which you'd like to create the bloc/cubit and select the command from the context menu.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage.gif)

## Code Actions

| Action                               | Description                                                            |
| ------------------------------------ | ---------------------------------------------------------------------- |
| `Convert to MultiBlocListener`       | Converts current `BlocListener` into a `MultiBlocListener`             |
| `Convert to MultiBlocProvider`       | Converts current `BlocProvider` into a `MultiBlocProvider`             |
| `Convert to MultiRepositoryProvider` | Converts current `RepositoryProvider` into a `MultiRepositoryProvider` |
| `Wrap with BlocBuilder`              | Wraps current widget in a `BlocBuilder`                                |
| `Wrap with BlocSelector`             | Wraps current widget in a `BlocSelector`                               |
| `Wrap with BlocListener`             | Wraps current widget in a `BlocListener`                               |
| `Wrap with BlocConsumer`             | Wraps current widget in a `BlocConsumer`                               |
| `Wrap with BlocProvider`             | Wraps current widget in a `BlocProvider`                               |
| `Wrap with RepositoryProvider`       | Wraps current widget in a `RepositoryProvider`                         |

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/wrap-with-usage.gif)

## Snippets

### Bloc

| Shortcut            | Description                                   |
| ------------------- | --------------------------------------------- |
| `importbloc`        | Imports `package:bloc`                        |
| `importflutterbloc` | Imports `package:flutter_bloc`                |
| `importbloctest`    | Imports `package:bloc_test`                   |
| `bloc`              | Creates a bloc class                          |
| `cubit`             | Creates a cubit class                         |
| `onevent`           | Register a new `EventHandler`                 |
| `_onevent`          | Define a new `EventHandler`                   |
| `blocobserver`      | Creates a `BlocObserver` class                |
| `blocprovider`      | Creates a `BlocProvider` widget               |
| `multiblocprovider` | Creates a `MultiBlocProvider` widget          |
| `repoprovider`      | Creates a `RepositoryProvider` widget         |
| `multirepoprovider` | Creates a `MultiRepositoryProvider` widget    |
| `blocbuilder`       | Creates a `BlocBuilder` widget                |
| `blocselector`      | Creates a `BlocSelector` widget               |
| `bloclistener`      | Creates a `BlocListener` widget               |
| `multibloclistener` | Creates a `MultiBlocListener` widget          |
| `blocconsumer`      | Creates a `BlocConsumer` widget               |
| `blocof`            | Shortcut for `BlocProvider.of()`              |
| `repoof`            | Shortcut for `RepositoryProvider.of()`        |
| `read`              | Shortcut for `context.read()`                 |
| `watch`             | Shortcut for `context.watch()`                |
| `select`            | Shortcut for `context.select()`               |
| `blocstate`         | Creates a state class                         |
| `blocevent`         | Creates an event class                        |
| `bloctest`          | Creates a `blocTest`                          |
| `mockbloc`          | Creates a class extending `MockBloc`          |
| `_mockbloc`         | Creates a private class extending `MockBloc`  |
| `mockcubit`         | Creates a class extending `MockCubit`         |
| `_mockcubit`        | Creates a private class extending `MockCubit` |
| `fake`              | Creates a class extending `Fake`              |
| `_fake`             | Creates a private class extending `Fake`      |
| `mock`              | Creates a class extending `Mock`              |
| `_mock`             | Creates a private class extending `Mock`      |

### Freezed Bloc

| Shortcut | Description             |
| -------- | ----------------------- |
| `fstate` | Creates a freezed state |
| `fevent` | Creates a freezed event |
