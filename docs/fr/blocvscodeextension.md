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
<a href="https://discord.gg/Hc5KD3g"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

## Introduction

Bloc étend [VSCode](https://code.visualstudio.com/) avec le support de la librairie de [Bloc](https://bloclibrary.dev) et fournit les outils nécessaires pour créer des blocs à la fois pour des applications [Flutter](https://flutter.dev/) et [AngularDart](https://angulardart.dev/).

## Overview

Bloc peut être installé à partir de la [Marketplace VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) ou [en cherchant dans VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Commandes

| Commande           | Description    |
| ------------------ | -------------- |
| `Bloc: New Bloc`   | Créer un Bloc  |
| `Cubit: New Cubit` | Créer un Cubit |

## Utilisation des nouvelles commandes pour Bloc

Vous pouvez activer la commande en ouvrant la palette de commande (View -> Command Palette) et en tapant la commande.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-1.gif)

Ou vous pouvez faire un clique droit sur le dossier dans lequel vous voudriez créer un bloc/cubit et sélectionnez la commande.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-2.gif)

## Utilisation des raccourcis(snipets)

### Bloc

| Raccourcis                | Description                                             |
| ------------------------- | ------------------------------------------------------- |
| `bloc`                    | Crée une Classe Bloc                                    |
| `blocbuilder`             | Crée un Widget BlocBuilder                              |
| `bloclistener`            | Crée un BlocListener Widget                             |
| `multibloclistener`       | Crée un widget MultiBlocListener                        |
| `blocconsumer`            | Crée un widget BlocConsumer                             |
| `blocprovider`            | Crée un widget BlocProvider                             |
| `multiblocprovider`       | Crée un widget MultiBlocProvider                        |
| `repositoryprovider`      | Crée un widget RepositoryProvider                       |
| `multirepositoryprovider` | Crée un widget MultiRepositoryProvider                  |
| `blocdelegate`            | Crée une Classe BlocDelegate                            |
| `contextbloc`             | Raccourcis pour `context.bloc<MyBloc>()`                |
| `blocof`                  | Raccourcis pour `BlocProvider.of<MyBloc>()`             |
| `contextrepository`       | Raccourcis pour `context.repository<MyRepository>()`    |
| `repositoryof`            | Raccourcis pour `RepositoryProvider.of<MyRepository>()` |

### Cubit

| Raccourcis           | Description                                   |
| -------------------- | --------------------------------------------- |
| `cubit`              | Crée une Classe Cubit                         |
| `cubitbuilder`       | Crée un Widget CubitBuilder                   |
| `cubitlistener`      | Crée un CubitListener Widget                  |
| `multicubitlistener` | Crée un widget MultiCubitListener             |
| `cubitconsumer`      | Crée un widget CubitConsumer                  |
| `cubitprovider`      | Crée un widget CubitProvider                  |
| `multicubitprovider` | Crée un widget MultiCubitProvider             |
| `contextcubit`       | Raccourcis pour `context.cubit<MyCubit>()`    |
| `cubitof`            | Raccourcis pour `CubitProvider.of<MyCubit>()` |
