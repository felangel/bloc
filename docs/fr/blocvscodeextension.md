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

Bloc étend [VSCode](https://code.visualstudio.com/) avec le support de la librairie de [Bloc](https://bloclibrary.dev) et fournit les outils nécessaires pour créer des blocs à la fois pour des applications [Flutter](https://flutter.dev/) et [AngularDart](https://angulardart.dev/).

## Overview

Bloc peut être installé à partir de la [Marketplace VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) ou [en cherchant dans VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Commandes

| Commande           | Description    |
| ------------------ | -------------- |
| `Bloc: New Bloc`   | Créer un Bloc  |
| `Cubit: New Cubit` | Créer un Cubit |

You can activate the commands by launching the command palette (View -> Command Palette) and running entering the command name or you can right click on the directory in which you'd like to create the bloc/cubit and select the command from the context menu.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage.gif)

## Code Actions

| Action                         | Description                                    |
| ------------------------------ | ---------------------------------------------- |
| `Wrap with BlocBuilder`        | Wraps current widget in a `BlocBuilder`        |
| `Wrap with BlocListener`       | Wraps current widget in a `BlocListener`       |
| `Wrap with BlocConsumer`       | Wraps current widget in a `BlocConsumer`       |
| `Wrap with BlocProvider`       | Wraps current widget in a `BlocProvider`       |
| `Wrap with RepositoryProvider` | Wraps current widget in a `RepositoryProvider` |

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/wrap-with-usage.gif)

## Utilisation des raccourcis(snipets)

### Bloc

| Shortcut            | Description                               |
| ------------------- | ----------------------------------------- |
| `bloc`              | Crée une Classe `Bloc`                    |
| `cubit`             | Crée une Classe `Cubit`                   |
| `blocobserver`      | Crée une Classe `BlocObserver`            |
| `blocprovider`      | Crée un Widget `BlocProvider`             |
| `multiblocprovider` | Crée un Widget `MultiBlocProvider`        |
| `repoprovider`      | Crée un Widget `RepositoryProvider`       |
| `multirepoprovider` | Crée un Widget `MultiRepositoryProvider`  |
| `blocbuilder`       | Crée un Widget `BlocBuilder`              |
| `bloclistener`      | Crée un Widget `BlocListener`             |
| `multibloclistener` | Crée un Widget `MultiBlocListener`        |
| `blocconsumer`      | Crée un Widget `BlocConsumer`             |
| `blocof`            | Raccourcis pour `BlocProvider.of()`       |
| `repoof`            | Raccourcis pour `RepositoryProvider.of()` |
| `read`              | Raccourcis pour `context.read()`          |
| `watch`             | Raccourcis pour `context.watch()`         |
| `select`            | Raccourcis pour `context.select()`        |
| `blocstate`         | Crée une Classe state                     |
| `blocevent`         | Crée une Classe event                     |

### Freezed Bloc

| Shortcut     | Description                                                     |
| ------------ | --------------------------------------------------------------- |
| `feventwhen` | Creates a map event to state function with freeze.when function |
| `feventmap`  | Creates a map event to state function with freeze.map function  |
| `fstate`     | Creates a sub state                                             |
| `fevent`     | Creates a sub event                                             |
