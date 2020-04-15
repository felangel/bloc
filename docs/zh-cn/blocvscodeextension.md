# Bloc Extension for VSCode

[![build](https://github.com/felangel/bloc/workflows/build/badge.svg)](https://github.com/felangel/bloc/actions)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=Stars)](https://github.com/felangel/bloc)

[![Version](https://vsmarketplacebadge.apphb.com/version-short/FelixAngelov.bloc.svg)](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)
[![Install](https://vsmarketplacebadge.apphb.com/installs-short/FelixAngelov.bloc.svg)](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)
[![Ratings](https://vsmarketplacebadge.apphb.com/rating-short/FelixAngelov.bloc.svg)](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)
[![Flutter Website](https://img.shields.io/badge/Flutter-Website-deepskyblue.svg)](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter#standard)
[![Flutter Samples](https://img.shields.io/badge/Flutter-Samples-teal.svg?longCache=true)](http://fluttersamples.com)
[![Discord](https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue)](https://discord.gg/Hc5KD3g)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

## Introduction

Bloc extends [VSCode](https://code.visualstudio.com/) with support for the [Bloc](https://bloclibrary.dev) library and provides tools for effectively creating Blocs for both [Flutter](https://flutter.dev/) and [AngularDart](https://angulardart.dev/) apps.

## Installation

Bloc can be installed from the [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) or by [searching within VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## New Bloc Command Usage

The New Bloc Command allows you to create a Bloc and the Events/States so that all that's left to do is implement your logic in `mapEventToState`.

You can active the command by launching the command palette (View -> Command Palette) and running "Bloc: New Bloc".

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-1.gif)

Or you can right click on the directory in which you'd like to create the bloc and select the "Bloc: New Bloc" command from the context menu.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-2.gif)

## Snippets Usage

| Shortcut                  | Description                                          |
| ------------------------- | ---------------------------------------------------- |
| `bloc`                    | Creates a Bloc Class                                 |
| `blocbuilder`             | Creates a BlocBuilder Widget                         |
| `bloclistener`            | Creates a BlocListener Widget                        |
| `multibloclistener`       | Creates a MultiBlocListener Widget                   |
| `blocconsumer`            | Creates a BlocConsumer Widget                        |
| `blocprovider`            | Creates a BlocProvider Widget                        |
| `multiblocprovider`       | Creates a MultiBlocProvider Widget                   |
| `repositoryprovider`      | Creates a RepositoryProvider Widget                  |
| `multirepositoryprovider` | Creates a MultiRepositoryProvider Widget             |
| `blocdelegate`            | Creates a BlocDelegate Class                         |
| `contextbloc`             | Shortcut for `context.bloc<MyBloc>()`                |
| `blocof`                  | Shortcut for `BlocProvider.of<MyBloc>()`             |
| `contextrepository`       | Shortcut for `context.repository<MyRepository>()`    |
| `repositoryof`            | Shortcut for `RepositoryProvider.of<MyRepository>()` |
