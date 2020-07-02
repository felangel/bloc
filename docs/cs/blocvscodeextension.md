# Bloc Extension for VSCode

[![build](https://github.com/felangel/bloc/workflows/build/badge.svg)](https://github.com/felangel/bloc/actions)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=Stars)](https://github.com/felangel/bloc)

[![Version](https://vsmarketplacebadge.apphb.com/version-short/FelixAngelov.bloc.svg)](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)
[![Install](https://vsmarketplacebadge.apphb.com/installs-short/FelixAngelov.bloc.svg)](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)
[![Ratings](https://vsmarketplacebadge.apphb.com/rating-short/FelixAngelov.bloc.svg)](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)
[!Flutter Website(https://img.shields.io/badge/Flutter-Website-deepskyblue.svg)](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter#standard)
[![Flutter Samples](https://img.shields.io/badge/Flutter-Samples-teal.svg?longCache=true)](http://fluttersamples.com)
[![Discord](https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue)](https://discord.gg/Hc5KD3g)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

## Úvod

[VSCode](https://code.visualstudio.com/) rozšíření Blocu pro podporou knihovny [Bloc](https://bloclibrary.dev) a poskytování efektivních nástrojů pro efektivní vytváření Bloců jak ve [Flutter](https://flutter.dev/), tak i [AngularDart](https://angulardart.dev/) aplikacích.

## Instalace

Bloc může být nainstalován z [VSCode obchodu](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) nebo [vyhledáním ve VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Jak používat příkaz New Bloc

Příkaz New Bloc umožňuje vytvořit Bloc a Události/Stavy tak, abyste museli doimplementovat pouze logiku v `mapEventToState`.

Můžete aktivovat příkaz spuštěním palety příkazů (View -> Command Palette) a spuštěním "Bloc: New Bloc".

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-1.gif)

Nebo můžete kliknout pravým tlačítkem na složku, ve které chcete vytvořit bloc a vybrat příkaz "Bloc: New Bloc" z kontextové nabídky.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-2.gif)

## Jak používat úryvky

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
| `blocobserver`            | Creates a BlocObserver Class                         |
| `contextbloc`             | Shortcut for `context.bloc<MyBloc>()`                |
| `blocof`                  | Shortcut for `BlocProvider.of<MyBloc>()`             |
| `contextrepository`       | Shortcut for `context.repository<MyRepository>()`    |
| `repositoryof`            | Shortcut for `RepositoryProvider.of<MyRepository>()` |
