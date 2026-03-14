<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/logos/bloc.png" height="100" alt="Bloc" />
</p>

<p align="center">
<a href="https://github.com/felangel/bloc/actions"><img src="https://github.com/felangel/bloc/actions/workflows/main.yaml/badge.svg" alt="build"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://discord.gg/bloc"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
</p>

---

## Overview

[Zed](https://zed.dev) support for the [Bloc Library](https://bloclibrary.dev) providing snippets and the Bloc language server for [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/) apps.

## Installation

Install from the Zed Extensions panel by searching for "Bloc", or install as a dev extension for local development:

1. Open Zed
2. Open the command palette and run `zed: install dev extension`
3. Select the `extensions/zed` directory

## Language Server

The Bloc language server provides custom diagnostic reporting for bloc-related lint rules. See [the official documentation](https://bloclibrary.dev/lint) for more information about configuring the linter and supported lint rules.

The language server binary (`bloc_tools`) is automatically downloaded from [GitHub releases](https://github.com/felangel/bloc/releases).

## Snippets

### Bloc

| Shortcut            | Description                                   |
| ------------------- | --------------------------------------------- |
| `importbloc`        | Imports `package:bloc`                        |
| `importflutterbloc` | Imports `package:flutter_bloc`                |
| `importbloctest`    | Imports `package:bloc_test`                   |
| `bloc`              | Creates a Bloc class                          |
| `cubit`             | Creates a Cubit class                         |
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
