# Extension Bloc pour VSCode

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

Bloc étend [VSCode](https://code.visualstudio.com/) avec le support de la librairie de [Bloc](https://bloclibrary.dev) et fournit les outils nécessaires pour créer des blocs à la fois pour des applications [Flutter](https://flutter.dev/) et [AngularDart](https://angulardart.dev/).

## Installation

Bloc peut être installé à partir de la [Marketplace VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) ou [en cherchant dans VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Utilisation des nouvelles commandes pour Bloc

Les nouvelles commandes Bloc vous permet de créer un Bloc avec les Events/States donc tout ce qu'il vous restera à faire et d'implémenter votre logique dans `mapEventToState`.

Vous pouvez activer la commande en ouvrant la palette de commande (View -> Command Palette) et en tapant "Bloc: New Bloc".

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-1.gif)

Ou vous pouvez faire un clique droit sur le dossier dans lequel vous voudriez créer un bloc et sélectionnez "Bloc: New Bloc".

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-2.gif)

## Utilisation des raccourcis(snipets)

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
